# Cloud Function Hands-on

## Pre-requis
### Attention de bien être identifié avec votre compte Wescale
### Configurer le projet GCP par défaut. C'est le projet où nous allons déployer les fonctions.

```bash
gcloud config set project xxxx
```
### Noter que l'ensemble des codes à utiliser se trouve dans **functions/**
### Pour éviter de rentrer en conflit avec les autres participants merci de prefixer le nom de vos functions avec un identifiant (et joueur le jeux).
Pour avoir ce prefix automatiquement dans le tutoriel l'exporter sous forme d'env variable dans votre session:
```bash
export MY_ID=xxxx
```

## Deployer ma première *cloud-function*
L'objectif est de déployer une première fonction HTTP.  
Nous allons deployer la fonction <walkthrough-editor-open-file
filePath="functions/simple-http-function/main.py">
simple-http-function
</walkthrough-editor-open-file>  

### Placer vous dans le dossier de la fonction
```bash
cd functions/simple-http-function/
```
### Deployer la fonction
```bash
gcloud functions deploy "${MY_ID}-simple-http" --region=europe-west1 \
--runtime python310 --trigger-http --entry-point=handle_request \
--allow-unauthenticated
```

### Vérifier que la fonction est bien déployée: 
Dans la console aller sur la liste des fonctions:
[ici](https://console.cloud.google.com/functions/list)
et aller sur la page de votre fonction. Vous pouvez voir notamment: 
- Les metrics
- La configuration
- L'URL HTTP dans la partie trigger
- Les logs

### Tester la cloud function

```bash
curl <CLOUD_FUNCTION_URL>?who=blabla
```
Vous devriez avoir en retour: 
**Hello blabla**
