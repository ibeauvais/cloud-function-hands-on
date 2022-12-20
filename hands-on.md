# Cloud Function Hands-on

## Pre-requis
### - Attention de bien être identifié avec votre compte Wescale
### - Configurer le projet GCP par défaut. C'est le projet où nous allons déployer les fonctions.

```bash
gcloud config set project xxxx
```
### - Noter que l'ensemble des codes à utiliser se trouve dans **functions/**
### - Pour éviter de rentrer en conflit avec les autres participants merci de prefixer le nom de vos functions avec un identifiant (et joueur le jeux).
Pour avoir ce prefix automatiquement dans le tutoriel l'exporter sous forme d'env variable dans votre session:
```bash
export MY_ID=xxxx
```

## Deployer ma première *cloud-function*
L'objectif est de déployer une première fonction HTTP.  
Nous allons deployer la fonction
<walkthrough-editor-open-file filePath="cloud-function-hands-on/functions/simple-http-function/main.py">simple-http-function</walkthrough-editor-open-file>


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
- Il est possible de récupérer l'URL avec la commande:
```bash
gcloud functions describe "${MY_ID}-simple-http" --region=europe-west1 --format="value(httpsTrigger.url)"
```

## Authentification
Les appels à la fonction ne sont pas authentifiés, c'est le moment de changer ça.

Lors de l'appel précédent le paramètre `--allow-unauthenticated` a eu pour effet d'ajouter le rôle **cloudfunctions.invoker** à tous le monde et donc permettre l'invocation de cette fonction sans authentification. Vous pouvez voir cette permission dans l'onglet permissions de votre cloud function.

### Ajouter l'authentification:
Supprimer le droit donné à tous le monde d'invoquer la fonction:
```bash
gcloud functions remove-iam-policy-binding "${MY_ID}-simple-http" --region=europe-west1 --member=allUsers --role=roles/cloudfunctions.invoker
```

### Test sans authentification:
*Attention pour que la modification soit prise en compte il faut parfois quelques secondes.*
```bash
curl <CLOUD_FUNCTION_URL>?name=blabla
```
Doit renvoyer l'erreur suivante:
```html
<html><head>
<meta http-equiv="content-type" content="text/html;charset=utf-8">
<title>403 Forbidden</title>
</head>
<body text=#000000 bgcolor=#ffffff>
<h1>Error: Forbidden</h1>
<h2>Your client does not have permission to get URL <code>/ibe-simple-http?name=blabla</code> from this server.</h2>
<h2></h2>
</body></html>
```

### Authentification
Pour pouvoir authentifier votre appel http vous devez passer votre token d'authentification. Avec curl donc:
```bash
curl -H "Authorization: bearer $(gcloud auth print-identity-token)"  <CLOUD_FUNCTION_URL>?name=blabla
```


### Info +:
Vous avez pu appeler votre fonction avec votre identité car la permission `cloudfunctions.functions.invoke` vous a été donné sur le projet du hands-on via le rôle **cloudfunctions.invoker**.


## Modification de la fonction:
La fonction répond à toutes les requêtes avec le même comportement.
Vous allez modifier la fonction avec <walkthrough-editor-open-file filePath="cloud-function-hands-on/functions/simple-http-function/main.py">l'éditeur</walkthrough-editor-open-file>


### Modifications du code:
Nous souhaitons que en fonction des requêtes elle ait le comportement suivant:
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
### Validation:
```bash
export TRIGGER_URL=$(gcloud functions describe "${MY_ID}-simple-http" --region=europe-west1 --format="value(httpsTrigger.url)")
```
GET
```bash
 curl -H "Authorization: bearer $(gcloud auth print-identity-token)" "${TRIGGER_URL}?name=blabla"
```

POST
```bash
 curl -X POST -H "Content-Type: application/json" -H "Authorization: bearer $(gcloud auth print-identity-token)" "${TRIGGER_URL}" -d '{"names":["name1", "name2"]}'
```

Other (HEAD)
```bash
 curl --head -H "Authorization: bearer $(gcloud auth print-identity-token)" "${TRIGGER_URL}?name=blabla"
```
