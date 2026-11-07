"""Static checks for reconstructed teaching manifests (not a live cluster test)."""
import unittest
from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[1]


def load(relative):
    with (ROOT / relative).open(encoding='utf-8') as f:
        return [x for x in yaml.safe_load_all(f) if x]


class K8sManifestsTest(unittest.TestCase):
    def test_all_manifests_parse(self):
        for path in (ROOT / 'manifests').rglob('*.yaml'):
            with self.subTest(path=path.name):
                for obj in load(path.relative_to(ROOT)):
                    self.assertIn(obj['kind'], ('Service', 'Deployment', 'PersistentVolume',
                                                 'PersistentVolumeClaim', 'DaemonSet',
                                                 'HorizontalPodAutoscaler'))
                    self.assertTrue(obj['metadata']['name'])
                    self.assertTrue(obj['apiVersion'])

    def test_nginx_services_select_deployment(self):
        dep=load('manifests/nginx/01-deployment.yaml')[0]
        services=load('manifests/nginx/02-services.yaml')
        self.assertEqual(dep['spec']['replicas'], 4)
        for svc in services:
            self.assertEqual(svc['spec']['selector'], dep['spec']['template']['metadata']['labels'])
        nodeport=next(x for x in services if x['spec']['type']=='NodePort')
        self.assertEqual(nodeport['spec']['ports'][0]['nodePort'], 30100)

    def test_mysql_storage_wiring(self):
        pv=load('manifests/mysql/01-local-pv.yaml')[0]
        pvc=load('manifests/mysql/02-mysql-pvc.yaml')[0]
        dep=load('manifests/mysql/03-mysql-deployment.yaml')[0]
        self.assertEqual(pv['metadata']['name'], pvc['spec']['volumeName'])
        self.assertEqual(pv['spec']['capacity']['storage'], '1Gi')
        self.assertEqual(pv['spec']['persistentVolumeReclaimPolicy'], 'Retain')
        self.assertEqual(dep['spec']['replicas'], 1)
        self.assertEqual(dep['spec']['template']['spec']['volumes'][0]['persistentVolumeClaim']['claimName'], pvc['metadata']['name'])
        env=dep['spec']['template']['spec']['containers'][0]['env'][0]
        self.assertEqual(env['valueFrom']['secretKeyRef']['name'], 'mysql-credentials')

    def test_cpu_limits(self):
        baseline=load('manifests/resources/01-cpu-stress-baseline.yaml')[0]
        limited=load('manifests/resources/02-cpu-stress-limited.yaml')[0]
        self.assertEqual(baseline['metadata']['name'], limited['metadata']['name'])
        c=limited['spec']['template']['spec']['containers'][0]
        self.assertEqual(c['resources']['requests']['cpu'], '150m')
        self.assertEqual(c['resources']['limits']['cpu'], '300m')

    def test_hpa_target(self):
        dep=load('manifests/hpa/01-php-apache.yaml')[0]
        hpa=load('manifests/hpa/02-hpa.yaml')[0]
        self.assertEqual(hpa['spec']['scaleTargetRef']['name'], dep['metadata']['name'])
        self.assertEqual(hpa['spec']['metrics'][0]['resource']['target']['averageUtilization'], 27)
        self.assertGreaterEqual(hpa['spec']['maxReplicas'], 7)

    def test_iperf3_server_discovery(self):
        dep,svc=load('manifests/iperf3/01-iperf3-server.yaml')
        clients=load('manifests/iperf3/02-iperf3-clients.yaml')[0]
        self.assertEqual(dep['spec']['replicas'], 1)
        self.assertEqual(svc['spec']['type'], 'ClusterIP')
        self.assertEqual(svc['spec']['selector'],dep['spec']['template']['metadata']['labels'])
        self.assertEqual(svc['spec']['ports'][0]['port'], 5201)
        self.assertEqual(clients['kind'],'DaemonSet')

if __name__=='__main__':
    unittest.main()
