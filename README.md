# Sizing platefome kubernetes - Kafka BOA
## Besoins
- Environnment: AKS Cloud AZURE
- Nombres de clusters: 3 (dev, preprod, prod)
- Nombres de namespace par environnement: 16 namespaces kafka (dev: 1 controller + 1 broker par namespace, preprod et prod 3 controller + 3broker par namespace)

## Sizing des clusters
Ce document propose un sizing de départ, pas un dimensionnement définitif

|  Parameters | AKS DEV | AKS PREPROD | AKS PROD |
|:-------- |:--------:| --------:| --------:|
| vm size (Default Pool)    | Standard_D4s_v5   | Standard_D4ds_v5    | Standard_D4as_v5 |
| vm size (App Pool)    | Standard_D4s_v5   | Standard_D4ds_v5    | Standard_D8ds_v5 |
| node count     | 3   | 4    | 7 |
| max pod     | 110  | 110  | 110 |
| Os Disk Size     | 50  | 50  | 50 |
| OS disk Type | Managed | Managed | Managed |
| Pod CIDR | 188.10.0.0/16 | 188.11.0.0/16 | 188.12.0.0/16 |
| Service CIDR | 198.10.0.0/16 | 198.11.0.0/16 | 198.12.0.0/16 |
| Node Type | VirtualMachineScaleSets | VirtualMachineScaleSets | VirtualMachineScaleSets |
| Kubernetes Version | 1.33.5 | 1.33.5 | 1.33.5 |
| Outbound Type | LoadBalancer | LoadBalancer | LoadBalancer |
| CNI | Azure CNI Overlay | Azure CNI Overlay | Azure CNI Overlay
| Auto scaling | Enabled  | Enabled | Enabled | 
| AKS SKU | Standard | Standard | Standard |
| AKS DNS IP | 198.10.0.10 | 198.11.0.10 | 198.12.0.10 |
| AKS Private | Enabled | Enabled | Enabled | 
| AKS Workload Identity | Enabled | Enabled | Enabled |
| AKS OIDC | Enabled | Enabled | Enabled |
| AKS RBAC | Enabled | Enabled | Enabled | 
| ACR SKU | Premium | Premium | Premium |
| ACR Public Enabled | No | No | No |
| ACR Network Rule set | Enabled | Enabled | Enabled | 
| ACR Content Trust | Disabled | Disabled | Disabled |


## Infrastructure existants

|  Ressources Azure | AKS DEV | AKS PREPROD | AKS PROD |
|:-------- |:--------:| --------:| --------:|
| Resource Group | RG-DEV | RG-PREPROD | RG-PROD |
| Vnet | VNET-KUB-DEV | VNET-KUB-PREPROD-NEW| VNET-KUB-PROD_NEW |
| Subnet | default | default | default |
| Subnet CIDR | 10.110.0.0/24 | 10.150.0.0/24| 10.160.0.0/24 |
| Entra ID User Group AKS Admin | GRP_KUB_DEV | GRP_KUB_PREPROD | GRP_KUB_PRDO |


## Déploiement des clusters avec Terraform
#### Prèrequis et Outils
- Terraform
- kubectl
- kubelogin
- git 

#### Permissions sur azure dont devez avoir
- Role __Contributor__ sur la souscription __Global Subscription BOA HOLDING CSP__
- Role __Owner__ sur les ressources Groups __RG-KUB-DEV__, __RG-KUB-PREPROD__, __RG-KUB-PROD__
- Role en lecture sur les group Azure Entra ID __GRP_KUB_DEV__, __GRP_KUB_PREPROD__, __GRP_KUB_PROD__

#### Récupération du code
- Cloner le repository

#### Déploiement
- Sur l'environnement de DEV
    - ``` cd aks-kafka/dev ```
    - ```terrafom init```
    - ```terraform plan```
    - ```terraform apply```

- Sur l'environnement de PREPROD
    - ``` cd aks-kafka/preprod ```
    - ```terrafom init```
    - ```terraform plan```
    - ```terraform apply```

- Sur l'environnement de PROD
    - ``` cd aks-kafka/prod ```
    - ```terrafom init```
    - ```terraform plan```
    - ```terraform apply```


## Connection sur le cluster 
1. Recuperer le kubeconf du cluster dépuis le portal azure
2. Tapez les commandes ci-dessous
```
az account set --subscription <subscription_id>
az aks get-credentials --resource-group <rg-name> --name <cluster-name> --overwrite-existing
kubelogin convert-kubeconfig -l azurecli
```
3. Tester l'accès au cluster
```
kubectl get nodes
kubectl get pod -n kube-system
```

## Mise à jour du cluster pour rediriger les flux sortant vers PaloAlto
Pour rediriger les flux sortant du cluster vers PaloAlto, voici les actions à faire:
1. Associer la table routage au subnet sur lequel se trouve le cluter. <br>
Exemple pour le cluster de dev <br>
Dans le vnet _VNET-KUB-DEV_, subnet _default_, route table sélectionné __RT_KUB_DEV_TO_PALOALTO__, et enregistrer.

2. Changer le __output_type__ de __loadBalancer__ à __userDefinedRoute__ <br>
Exemple pour le cluster de dev
Dans le dossier dev du code terraform, modifier la ligne 105 du fichier __main.tf__ à __outbound_type : "userDefinedRouting"__

3. Déployer les mise à jour
```
terraform plan
```
```
terraform apply
```