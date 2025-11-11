
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.sa.v1alpha1 as sav1alpha1

_items = [
    metav1alpha1.E2ETest {
        metadata.name: ""
        spec = {
            crossplane.autoUpgrade.channel: "Rapid"
            defaultConditions: ["Ready"]
            manifests: [
                sav1alpha1.XBackstage {
                    metadata = {
                        name: "e2e-backstage"
                        uid: "e2e-test-123"
                    }
                    spec = {
                        parameters = {
                            id: "e2e-backstage-test"
                            region: "us-west-1"
                            providerConfigName: "default"
                            ingress = {
                                enabled: True
                                host: "backstage-solution-idp.upboundrocks.cloud"
                                clusterIssuer: "letsencrypt-prod"
                                className: "nginx"
                            }
                            replicas: 3
                            image = {
                                registry: "xpkg.upbound.io"
                                repository: "upbound/backstage"
                                tag: "v0.1.0"
                            }
                            config = {
                                app = {
                                    title: "e2e-backstage"
                                }
                                kubernetesIngestor = {
                                    mappings = {
                                        systemModel: "cluster-namespace"
                                    }
                                    components = {
                                        customWorkloadTypes: [
                                            {
                                                group: "aws.platform.upbound.io"
                                                apiVersion: "v1alpha1"
                                                plural: "xeks"
                                            }
                                            {
                                                group: "aws.platform.upbound.io"
                                                apiVersion: "v1alpha1"
                                                plural: "xnetworks"
                                            }
                                            {
                                                group: "aws.platform.upbound.io"
                                                apiVersion: "v1alpha1"
                                                plural: "xpodidentities"
                                            }
                                            {
                                                group: "pkg.crossplane.io"
                                                apiVersion: "v1"
                                                plural: "providers"
                                            }
                                        ]
                                    }
                                }
                            }
                            secretSync: [
                                {
                                    destRef = {
                                        name: "up-secret"
                                        namespace: "backstage"
                                    }
                                    sourceRef = {
                                        name: "e2e-backstage-test-robot-token"
                                        namespace: "crossplane-system"
                                    }
                                }
                            ]
                            infrastructure = {
                                externalDNS = {
                                    enabled: True
                                    route53ZoneId: "Z0115025YFQ7ZQF6BJ6N"
                                }
                                eks = {
                                    enabled: False
                                    clusterName: "configuration-gitops-backstage-cluster"
                                    accessConfig = {
                                        bootstrapClusterCreatorAdminPermissions: True
                                        authenticationMode: "API"
                                    }
                                    iam = {
                                        principalArn: "arn:aws:iam::609897127049:role/solutions-e2e-provider-aws"
                                    }
                                    version: "1.31"
                                    nodes = {
                                        count: 3
                                        instanceType: "t3.small"
                                    }
                                }
                            }
                        }
                    }
                }
            ]
            extraResources: [
                {
                    apiVersion: "pkg.crossplane.io/v1"
                    kind: "Configuration"
                    metadata.name: "configuration-aws-eks"
                    spec.package: "xpkg.upbound.io/upbound/configuration-aws-eks:v0.21.0"
                }
                {
                    apiVersion: "pkg.crossplane.io/v1"
                    kind: "Configuration"
                    metadata.name: "configuration-aws-network"
                    spec.package: "xpkg.upbound.io/upbound/configuration-aws-network:v1.0.0"
                }
                {
                    apiVersion: "aws.upbound.io/v1beta1"
                    kind: "ProviderConfig"
                    metadata.name: "default"
                    spec.credentials = {
                        source = "Upbound"
                        upbound = {
                            webIdentity = {
                                roleARN = "arn:aws:iam::609897127049:role/solutions-e2e-provider-aws"
                            }
                        }
                    }
                }
                {
                    apiVersion: "aws.platform.upbound.io/v1alpha1"
                    kind: "XNetwork"
                    metadata.name: "configuration-gitops-backstage-network"
                    spec.parameters = {
                        id: "uptest-gitops-backstage-cluster"
                        region: "us-west-1"
                        vpcCidrBlock: "192.168.0.0/16"
                        subnets: [
                            {
                                availabilityZone: "us-west-1b"
                                type: "public"
                                cidrBlock: "192.168.0.0/18"
                            }
                            {
                                availabilityZone: "us-west-1c"
                                type: "public"
                                cidrBlock: "192.168.64.0/18"
                            }
                            {
                                availabilityZone: "us-west-1b"
                                type: "private"
                                cidrBlock: "192.168.128.0/18"
                            }
                            {
                                availabilityZone: "us-west-1c"
                                type: "private"
                                cidrBlock: "192.168.192.0/18"
                            }
                        ]
                    }
                }
                {
                    apiVersion: "aws.platform.upbound.io/v1alpha1"
                    kind: "XEKS"
                    metadata.name: "configuration-gitops-backstage-cluster"
                    spec = {
                        parameters = {
                            accessConfig = {
                                authenticationMode = "API_AND_CONFIG_MAP"
                                bootstrapClusterCreatorAdminPermissions = True
                            }
                            id = "uptest-gitops-backstage-cluster"
                            nodes = {
                                count = 3
                                instanceType = "t3.small"
                            }
                            region = "us-west-1"
                            version = "1.27"
                        }
                        writeConnectionSecretToRef = {
                            name = "configuration-gitops-backstage-kubeconfig"
                            namespace = "upbound-system"
                        }
                    }
                }
            ]
            skipDelete: False
            timeoutSeconds: 4500
        }
    }
]
items = _items