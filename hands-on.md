# Cloud Function Hands-on


## Prérequis

 - Vous aurez besoin de votre compte Google Wescale
 - Configurer le projet GCP `cloud-function-hands-on` par défaut. Nous allons l'utiliser pour déployer les fonctions.

```bash
gcloud config set project cloud-function-hands-on
```

 - Notez que l'ensemble du code que nous manipulerons se trouvera dans `functions/`
 - Pour faciliter le hands-on, merci de choisir un `ID` alphanumérique. 
Vous l'utiliserez lors de vos déploiements de function dans le projet `cloud-function-hands-on` afin d'avoir un nom unique

Définissez votre `ID` de projet dans votre environnement :

```bash
export MY_ID=xxxx
```


## Cloud Function Pub/Sub

Pour notre première création de **Cloud Function**, nous allons commencer par une fonction qui écoute les messages envoyés dans un topic Pub/Sub.  

**Note :**

- Pour envoyer des messages de type Pub/Sub, il est nécessaire de créer un topic.
- L'objectif de cette première partie est d'écouter les messages qui sont envoyés dans ce topic et de réagir à ces messages.

Nous allons deployer la fonction
<walkthrough-editor-open-file filePath="cloud-function-hands-on/functions/pubsub-function/main.py">functions/pubsub-function</walkthrough-editor-open-file>


### Création du topic

```bash
gcloud pubsub topics create "${MY_ID}-messages"
```

Un message vous indiquera que le topic est bien créé.

### Déploiement/Redéploiement de la Cloud Function

Placer vous dans le dossier contenant le code de la Cloud Function :

```bash
cd functions/pubsub-function/
```

Déployer la Cloud Function avec cette commande :

```bash
gcloud functions deploy "${MY_ID}-pubsub-function" --region=europe-west1 \
--runtime python310 --trigger-topic "${MY_ID}-messages"  --entry-point=handle_message 
```

**Important :**

- Cette commande sera très utilisée dans ce hands-on, elle vous servira pour tout déploiement ou **redeploiement** d'une Cloud Function.
- Vous devez être dans le dossier contenant le `main.py` pour déployer votre Cloud Function.

### Info +
A propos de cette commande  `gcloud functions deploy`:
- Le paramètre `entry-point` permet de spécifier la méthode qui traitera le message dans `main.py`.
- Une image docker a été construite avec [Google Cloud's buildpacks](https://cloud.google.com/docs/buildpacks/build-function)
- Cette construction est réalisée par le service [Cloud Build](https://cloud.google.com/build)

### Vérification de la Cloud Function

Dans la console, consultez sur la liste des [Cloud Functions](https://console.cloud.google.com/functions/list)
et sélectionnez votre fonction `{MY_ID}-pubsub-function`. Vous verrez notamment :

- Les métriques
- Le détail
- Le topic Pub/Sub dans le déclencheur
- Les journaux d'informations

### Test de la Cloud Function

Envoyez un message dans le topic précédemment créé :

```bash
gcloud pubsub topics publish "${MY_ID}-messages" --message="hello ${MY_ID}"
```

Ensuite consulter les journaux de votre Cloud Function, vous devriez voir votre message.


## Journalisation Cloud Function

Comme vous l'avez sans doute remarqué, les journaux générés lors des étapes précédentes n'ont pas de niveau : ils sont dans un statut *par défaut*. 
Nous allons donc modifier notre code Python afin d'utiliser des modules de journalisation et pouvoir remonter les informations sous différents niveaux. 
Nous allons aussi devoir ajouter les dépendances de ces modules à installer lors du déploiement de la Cloud Function.

### Ajout des dépendances Python

En Python, pour centraliser les dépendances d'un project, il est recommandé d'utiliser un fichier `requirements.txt`.

>Pour plus de [documentation](https://cloud.google.com/functions/docs/writing/specifying-dependencies-python?hl=fr).

Vous devez le créer au même niveau que le fichier `main.py` de votre Cloud Function et y inscrire les dépendances souhaitées :

```
google-cloud-logging==2.7.0
```

### Intégration de la journalisation avec Cloud Logging

Ajouter le code suivant avant la méthode `handle_message` dans <walkthrough-editor-open-file filePath="cloud-function-hands-on/functions/pubsub-function/main.py">main.py</walkthrough-editor-open-file>:

```python
import google.cloud.logging
import logging

# Init cloud logging
client = google.cloud.logging.Client()
client.get_default_handler()
client.setup_logging()
```

Cela activera la journalisation dans votre Cloud Function. Remplacez l'occurrence `print(pubsub_message)` par:

```python
logging.info(pubsub_message)
```

Vous pouvez également préciser le niveau de journalisation avec les méthodes de la classe `logging` :

```python
logging.warning("my warning")
logging.error("my error")
```

### Redéploiement de la Cloud Function

Utiliser la même commande que lors du déploiement initial.

### Validation de la journalisation de la Cloud Function

```bash
gcloud pubsub topics publish "${MY_ID}-messages" --message="hello logging ${MY_ID} "
```

Ensuite consulter les journaux de votre Cloud Function, vous devriez voir votre message ainsi que le niveau de journalisation.


## Cloud Function HTTP

Notre deuxième objectif est de déployer une fonction qui interagira à une requête HTTP.  
Nous allons deployer la fonction
<walkthrough-editor-open-file filePath="cloud-function-hands-on/functions/simple-http-function/main.py">simple-http-function</walkthrough-editor-open-file>

### Déploiement/Redéploiement de la Cloud Function

Placer vous dans le dossier contenant le code de la Cloud Function :

```bash
cd ../simple-http-function/
```

Déployer la Cloud Function avec cette commande :

```bash
gcloud functions deploy "${MY_ID}-simple-http" --region=europe-west1 \
--runtime python310 --trigger-http --entry-point=handle_request \
--allow-unauthenticated
```

### Info +
A propos de cette commande  `gcloud functions deploy`:

- Le paramètre `trigger-http` permet de spécifier le type d'appel envoyé à la Cloud Function.
- Le paramètre `allow-unauthenticated` permet une utilisation publique de la Cloud Function, sans authentification au préalable.

### Vérification de la Cloud Function

Dans la console, consultez sur la liste des [Cloud Functions](https://console.cloud.google.com/functions/list)
et sélectionnez votre fonction `{MY_ID}-simple-http`. Vous verrez notamment :

- Les métriques
- Le détail
- L'URL de déclenchement dans le déclencheur. **À récupérer**
- Les journaux d'informations

### Test de la Cloud Function

Vous pouvez récupérer l'URL de déclenchement par un appel API. Pour plus de simplicité, nous allons l'exporter dans notre environnement :

```bash
export URL_SIMPLE_HTTP=$(gcloud functions describe "${MY_ID}-simple-http" --region=europe-west1 --format="value(httpsTrigger.url)")
```

Testons notre fonction par un simple appel `curl` :

```bash
curl "${URL_SIMPLE_HTTP}?name=blabla"
```

Vous devriez avoir en retour `Hello blabla`

## Authentification

Comme vu précédemment, par l'utilisation du paramètre `allow-unauthenticated`, les appels à la fonction sont publiques, car non authentifiés. 
Ce paramètre ajoute le rôle `cloudfunctions.invoker` à `allUsers` et permet l'invocation de cette fonction sans authentification. 
Cette permission se trouve dans l'onglet autorisations de votre Cloud Function. 
Nous allons voir comment sécuriser l'appel à cette Cloud Function.

### Suppression du droit publique d'invocation

Supprimez le droit donné à tous le monde d'invoquer la fonction :

```bash
gcloud functions remove-iam-policy-binding "${MY_ID}-simple-http" --region=europe-west1 --member=allUsers --role=roles/cloudfunctions.invoker & sleep 30
```

**Notes :**

La propagation de cette modification peut prendre jusqu'à 30 secondes. D'où le `& sleep 30` à la fin de cette commande. 🙈🙉🙊

### Vérification de la suppression du droit

Appelez votre fonction aec un simple appel `curl` :

```bash
curl "${URL_SIMPLE_HTTP}?name=blabla"
```

Vous devez recevoir un retour de la fonction avec une erreur de ce type :

```html
<html><head>
<meta http-equiv="content-type" content="text/html;charset=utf-8">
<title>403 Forbidden</title>
</head>
<body text=#000000 bgcolor=#ffffff>
<h1>Error: Forbidden</h1>
<h2>Your client does not have permission to get URL <code>/xxx-simple-http?name=blabla</code> from this server.</h2>
<h2></h2>
</body></html>
```

### Authentification par token

Afin d'authentifier votre requête HTTP, vous devez utiliser un token d'authentification. Pour plus de simplicité, nous allons l'exporter dans notre environnement :

```bash
export MY_TOKEN=$(gcloud auth print-identity-token)
```

Et avec `curl`, vous utilisez cette commande :

```bash
curl -H "Authorization: bearer ${MY_TOKEN}"  "${URL_SIMPLE_HTTP}?name=blabla"
```

### Info +:

- Vous avez pu appeler votre fonction avec votre identité car la permission `cloudfunctions.functions.invoke` vous a été donné sur le projet du hands-on via le rôle **cloudfunctions.invoker**.


## Utilisation de différentes méthodes HTTP:
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
        return Response("ok method GET", status=200)
```

```python
from flask import Response

def handle_request(request):
    payload_json:dict=request.get_json()
    return payload_json["field1"]
```

### Re-deploiement
Vous devez redéployer la fonction HTTP avec la commande deploy mais sans le  paramètre `--allow-unauthenticated`:
```bash
gcloud functions deploy "${MY_ID}-simple-http" --region=europe-west1 \
--runtime python310 --trigger-http --entry-point=handle_request
```
### Validation:
On commence par stocker dans une variable l'URL de la Cloud Function:
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
