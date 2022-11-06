# DevOps

* [Tecnologias](#tecnologias) 
* [Provisionar VM](#provisionar-vm)
* [SSH](#ssh)
* [Clonar Projeto](#clonar-projeto)
* [Container](#container)
* [Cluster](#cluster)
* [Testes](#testes)
  - [App Node](#app-node)
  - [Postgre](#postgre)
* [Automação](#automação)
  - [CI](#ci)
  - [CD](#cd)

<p align="center">
   <img src="http://img.shields.io/static/v1?label=STATUS&message=EM%20DESENVOLVIMENTO&color=RED&style=for-the-badge" #vitrinedev/>
</p>


## Tecnologias



## Provisionar VM

<b> Máquina Local </b>

<p><b>1.</b> A ferramenta Terraform provisiona recursos em um Cloud Provider de forma declarativa, utilizando a linguagem HCL da Hashcorp.</p>

<p>Neste laboratório será provisionada umá máquina com a seguinte configuração:</p>

<p>
<ul>
<li> 1 CPU;</li>
<li> 2 GB de memória;</li>
<li> Sistema Operacional Ubuntu 20.04.</li>
</ul>
</p>

<p><b>2.</b> Acessar o diretório:</p>

``` bash
mkdir iac
cd iac
``` 

<p><b>3.</b> O arquivo "/iac/variable.tfvars" possui dados para construir a máquina virtual.

Ele contém dados sensiveis (token), e deve ser inserido no arquivio ".gitignore".

O "token" é gerado no menu "API" na página da Digital Ocean.

Já a regiao, imagem e size podem ser obtidas no site [Site Slugs](https://slugs.do-api.dev/5).

Estes dados serão utilizados no arquivo "/iac/main.tf" para construção da máquina virtual.

Conteúdo do arquivo variable.tfvars:</p>

``` tfvars
nome_droplet = "kubenews"
regiao       = "nyc1"
token        = "tokenGeradoNoCloudProvider"
imagem       = "ubuntu-20-04-x64"
size         = "s-1vcpu-2gb"
```

<p><b>4.</b> Iniciar o terraform, serão gerados arquivos de controle do terraform:</p>

```bash
terraform init
```

<p><b>5.</b> Formatar o arquivo (identar):</p>

``` bash
terraform fmt
```

<p><b>6.</b> Validar os arquivo com extensão "tf":</p> 

``` bash
terrafrom validate
```

<p><b>7.</b> Checa a declaração realizada nos arquivos com extensão "tf" antes de provisionar:</p>

``` bash
terraform plan
```

<p><b>8.</b> Aplicar o provisionamento, será solicitado uma confirmação digite "yes":</p> 

```
terraform apply
```

<p><b>9.</b> Será exibido o ip da máquina provisionada no serviço da Digital Ocean (saida do "iac/bloco-output.tf").</p>


## SSH

<b> Máquina Local </b>

<p><b>1.</b>A máquina virtual provisionada pelo TerraForm poderá ser acessada via ssh.
Execute o comando abaixo. Na primeira vez será solicitada uma confirmação digite "yes".
Em seguida será solicitada a palavara chave.</p>

``` bash
ssh root@ipDaMaquinaVirtual
```

## Clonar projeto

<b> Máquina Virtual </b>

<p><b>1.</b> Clonar o projeto KubeNews do GitHub:</p>

``` bash
git clone https://github.com/KubeDev/kube-news.git
```


## Container

<b> Máquina Virtual </b>

<p><b>1.</b> O arquivo "/src/Dockerfile" possui as instruções para construção da imagem:</p>

``` txt
FROM node:16.18.0
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8080
CMD  ["node","server.js"]
```

<p><b>2.</b> Criar a imagem:</p>

``` docker
docker build -t fabiocaettano74/kube-news:v1 -f Dockerfile .
docker image ls
```

<p><b>3.</b> Logar no Docker Hub:</p>

``` docker
docker login
```

<p><b>4.</b> Criar Tag:</p>

``` docker
docker tag fabiocaettano74/kube-news:v1 fabiocaettano74/kube-news:latest
```

<p><b>5.</b> Subir a imagem para o Docker Hub:</p>

``` docker
docker push fabiocaettano74/kube-news:v1
docker push fabiocaettano74/kube-news:latest
```


## Cluster

<b> Máquina Virtual </b>

<p><b>1.</b> Criar o Cluster com K3d:</p>

``` bash
k3d cluster create --servers 1 --agents 2 -p "8080:30000@loadbalancer"
```

<p><b>2.</b> Executar o deployment que irá criar o banco de dados Postgre, e subir aplicação desenvolvida em Node:</p>

``` bash
kubectl apply -f ./k8s/ -R
```

<p><b>3.</b> Checar o deploy:</p>

``` bash
kubectl get all
```

<p><b>4.</b> No manifesto é possivel aumentar e diminuir o número de réplicas do pod. Trecho do manifesto:</p>

``` yaml
spec:
  replicas: 6
```

<p><b>5.</b> Checar o histório de revisões:</p>

``` bash
kubectl rollout history deployment/kubenews
kubectl rollout history deployment/postgre
```

<p><b>6.</b> Checar revisão especifica:</p>

``` bash
kubectl rollout history deployment --revision=3
```

<p><b>7.</b> Retornar última versão:</p>

``` bash
kubectl rollout undo deployment kubenews
```

<p><b>8.</b> Retornar uma versão especifica:</p>

``` bash
kubectl rollout undo deployment/kubenews --to-revision=3
```

## Testes

### App Node

<p><b>1.</b> Na especificação do service da aplicação foi definido o port 80, targetPort 8080, nodePort 30000.

Na consulta ao service será visualizado o port e o nodePort:</p>

``` bash
kubectl get service
```

<p><b>2.</b>Para acessar aplicação via browser será utilizado o targetPort.</p>

```
http://ipDaMaquinaVirtual:8080/
```


### Postgre

<p><b>1.</b>O service do Banco de Dados é do tipo ClusterIp, não possibilitando o acesso direto.

Através do comando "kubectl port-forward" é possivel expor o serviço e acessar a base de dados.

Anotar o nome do pod:</p>

``` bash
kubectl get pods
```

<p><b>2.</b>Expondo a porta:</p>

``` bash
kubectl port-forward --address ipDaMaquinaVirtual nomeDoPod 5432:5432
```

<p><b>3.</b>Após expor a porta na máquina local execute o aplicativo DBeaver 22.2.0, e configure o acesso a base dados utilizando o ipDaMáquinaVirtual:5432.</p>


## Automação

Etapas da Integração Contínua:
Codificação >> Commit >> Build >> Teste >> Geração de Pacote

Etapas da Entrega Contínua:
Release >> Teste >> Aceite >> Deploy em Ambiente


### Secrets

<p><b>1.</b> Configurar Secrets na página do GitHub utilizando a opção:</p>

``` menu
Settings >> Secres >> Actions >> New Repository Secret
```

<p><b>2.</b> As credencias do Docker Hub devem ser cadastradas nos seguintes secrets:</p>

<ul>
<li>DOCKERHUB_USER</li>
<li>DOCKERHUB_PWD</li>
</ul>


<p><b>3.</b> As credenciais do Cluster podem ser obtidas no diretório .kube da máquina virtual:</p>

``` bash
cat ~\.kube\config
```

<p><b>4.</b>Colar estes valores no Secrets:</p>

<ul>
<li>KUBE_CONFIG</li>
</ul>

<p>Antes de salvar o SECRET altere a seguinte linha "server: https://0.0.0.0:porta" para "server: https://ipDaMaquiaVirtual:porta".</p>


### CI

<b> Fase da Integração Continua </b>

<p><b>1.</b> Criar a Pipeline na opção:</p>

``` html
Actions >>  set up a workflow yourself
```

<p><b>2.</b> Preencher o arquivo main.yaml com a estrutura abaixo:</p>

``` yaml
name: CI-CD

on:
  push:
    branches: ["main"]
  
  workflow_dispatch:
  
jobs:

  CI:
    runs-on: ubuntu-latest
  
    steps:
      - uses: actions/checkout@v3
      
      - name: Docker Login
        uses: docker/login-action@v2.1.0
        with:
          username: ${{secrets.DOCKERHUB_USER}}
          password: ${{secrets.DOCKERHUB_PWD}}
          
      - name: Build and push Docker images
        uses: docker/build-push-action@v3.2.0
        with:
          file: ./src/Dockerfile
          context: ./src
          push: true
          tags: |
            fabiocaettano74/kube-news:latest 
            fabiocaettano74/kube-news:${{github.run_number}}
```

<p><b>3.</b>As instruçoes para execução dos steps foi pesquisida na opção "Marketplace", e no campo "Search" pesquisar por:
- Docker Login
- Build and and push Docker Images

Os steps "Docker Login" realiza autenticação no Docker Hub.
Os dados sensiveis DOCKERHUB_USER e DOCKERHUB_PWD são acessados via secrets (recurso do GitHub)

E o step "Build and and push Docker Images" , constroi a imagem e realiza o push para o Docker Hub.
A versão da imagem é gerado pelo recurso "github.run_number".</p>


<p><b>4.</b> Inicie o processo clicando no botão "Start Commit" e depois em "Commit Changes".
Após isso clicar na opção "Actions", observe que haverá um processamento na cor "Laranja".
Clique nele para visualizar o processamento.</p>


### CD

<b>Fase da Entegra Continua</b>

<p><b>1.</b> Completar o arquivo main.yaml com as instruções para Entrega Continua:</p>

``` yaml
jobs:
  CI:
    ... 	
  CD
    runs-on: ubuntu-latest
    needs: [CI]    
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Kubernetes Set Context
        uses: Azure/k8s-set-context@v3.0
        with:
          method: kubeconfig
          kubeconfig: ${{secrets.K8S_CONFIG}}
      
      - name: Deploy to Kubernetes cluster
        uses: Azure/k8s-deploy@v4
        with:
          images: fabiocaettano74/kube-news:${{github.run_number}}
          manifests: |
            k8s/deployment.yaml 
```

<p><b>2.</b> As instruçoes para execução dos steps foi pesquisida na opção "Marketplace", e no campo "Search" pesquisar por:
- Kubernetes Set Context
- Deploy to Kubernetes cluster

O step "Kubernetes Set Context" faz autenticação no cluster através do arquivo config.

O step "Deploy to Kubernetes cluster" realizar o deploy conforme as instruções o arquivo deployent.yaml.</p>


<p><b>3.</b> Inicie o processo clicando no botão "Start Commit" e depois em "Commit Changes".
Após isso clicar na opção "Actions", observe que haverá um processamento na cor "Laranja".
Clique nele para visualizar o processamento.</p>


