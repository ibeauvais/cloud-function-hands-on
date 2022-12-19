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
curl <CLOUD_FUNCTION_URL>?name=blabla
```
Vous devriez avoir en retour: 
**Hello blabla**


### Info +: 
A propos de la commande  `gcloud functions deploy`: 
- Une image docker a été construite avec [Google Cloud's buildpacks](https://cloud.google.com/docs/buildpacks/build-function)
- Cette construction est réalisée par le service [Cloud Build](https://cloud.google.com/build)

## Authentification
Les appels à la fonction ne sont pas sécurisés.
### Ajouter l'authentification:
Supprimer le paramètre `--allow-unauthenticated` afin que appeler cette fonction nécéssite l'authentification.

### Test sans authentification: 
```bash
curl <CLOUD_FUNCTION_URL>?name=blabla
```
Doit renvoyer l'erreur suivante:


### Authentification
Pour pouvoir authentifier votre appel http vous devez passer votre token d'authentification. Avec curl donc:
```bash
curl -H "Authorization: bearer $(gcloud auth print-identity-token)"  <CLOUD_FUNCTION_URL>?name=blabla
```


### Info +:
Vous avez pu appeler votre fonction avec votre identité car la permission `cloudfunctions.functions.invoke` vous a été donné sur le projet du hands-on via le rôle **cloudfunctions.invoker**.


## Modification de la fonction:
La fonction répond à toutes les requêtes avec le même comportement.


### Modifications du code:
Nous souhaitons que en fonction des requêtes qu'elle ait le comportement suivant: 
- requête GET => Même comportement que actuelement 
- requête POST avec le payload suivant: 
 ```json
{
  "names": ["name1", "name2"]
}
```
**Réponse:**
```json
{
  "messages": ["hello name1","hello name2"]
}
```
- Autres méthodes http => code retour 405 

Quelques exemples de code pour vous aider:

```python
from flask import Response

def handle_request(request):
    if request.method == 'GET':
        return Response("method GET", status=400)
```

```python
from flask import Response

def handle_request(request):
    payload_json:dict=request.get_json()
    return payload_json["field1"]
```
