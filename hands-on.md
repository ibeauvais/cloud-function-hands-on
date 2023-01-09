# Cloud Function Hands-on


## Prérequis

- Vous aurez besoin de votre compte Google WeScale
- Configurer le projet GCP `cloud-function-hands-on` par défaut. Vous allez l'utiliser pour déployer les fonctions:

```bash
gcloud config set project cloud-function-hands-on
```

- Notez que l'ensemble du code que vous manipulerez se trouvera dans `functions/`
- Pour faciliter le hands-on, merci de choisir un `ID` alphanumérique.
Vous l'utiliserez lors de vos déploiements de function dans le projet `cloud-function-hands-on` afin d'avoir un nom unique

Définissez votre `ID` (**alphanumérique en minuscule**) de projet dans votre environnement :

```bash
export MY_ID=$(echo "my_lowercase_id" | tr '[:upper:]' '[:lower:]')
```

- Veuillez inscrire votre `ID` sur ce [Google Spreadsheet](https://docs.google.com/spreadsheets/d/1abBw26Bo_2IflzBB3QFtEVn4fcqFhpqQtSjMgC95y6U/edit?usp=sharing)

## Cloud Function Pub/Sub

Pour votre première création de **Cloud Function**, vous allez commencer par une fonction qui écoute les messages envoyés dans un topic Pub/Sub.

**Note :**

- Pour envoyer des messages de type Pub/Sub, il est nécessaire de créer un topic.
- L'objectif de cette première partie est d'écouter les messages qui sont envoyés dans ce topic et de réagir à ces messages.

Vous allez deployer la fonction
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
- Derrière la scène **Cloud Function** s'appuie sur d'autres services managés:
  - Une image docker a été construite avec [Google Cloud's buildpacks](https://cloud.google.com/docs/buildpacks/build-function)
  - Cette construction est réalisée par le service [Cloud Build](https://cloud.google.com/build)

### Vérification de la Cloud Function

Dans la console, consultez sur la liste des Cloud Functions [](https://console.cloud.google.com/functions/list)
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
Vous allez donc modifier votre code Python afin d'utiliser des modules de journalisation et pouvoir remonter les informations sous différents niveaux.
Vous allez aussi devoir ajouter les dépendances de ces modules à installer lors du déploiement de la Cloud Function.

### Ajout des dépendances Python

En Python, pour centraliser les dépendances d'un project, il est recommandé d'utiliser un fichier `requirements.txt`.

>Pour plus de [documentation](https://cloud.google.com/functions/docs/writing/specifying-dependencies-python?hl=fr).

A l'aide de l'éditeur cloud-shell, vous devez le créer au même niveau que le fichier <walkthrough-editor-open-file filePath="cloud-function-hands-on/functions/pubsub-function/main.py">main.py</walkthrough-editor-open-file> de votre Cloud Function et y inscrire les dépendances souhaitées :

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

Votre deuxième objectif est de déployer une fonction qui interagira à une requête HTTP.
Vous allez deployer la fonction
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

- Le paramètre `trigger-http` permet de spécifier le type de déclencheur utilisé par la Cloud Function.
- Le paramètre `allow-unauthenticated` permet une utilisation publique de la Cloud Function, sans authentification au préalable.

### Vérification de la Cloud Function

Dans la console, consultez sur la liste des Cloud Functions [](https://console.cloud.google.com/functions/list)
et sélectionnez votre fonction `{MY_ID}-simple-http`. Vous verrez notamment :

- Les métriques
- Le détail
- L'URL de déclenchement dans le déclencheur. **À récupérer**
- Les journaux d'informations

### Test de la Cloud Function

Vous pouvez récupérer l'URL de déclenchement par un appel API. Pour plus de simplicité, vous allez l'exporter dans votre environnement :

```bash
export URL_SIMPLE_HTTP=$(gcloud functions describe "${MY_ID}-simple-http" --region=europe-west1 --format="value(httpsTrigger.url)")
```
Cette URL a un format particulier qui dépend du projet GCP, de la région et du nom de la fonction:
```bash
echo $URL_SIMPLE_HTTP
```

Testons votre fonction par un simple appel `curl` :

```bash
curl "${URL_SIMPLE_HTTP}?name=blabla"
```

Vous devriez avoir en retour `Hello blabla`

## Authentification

Comme vu précédemment, par l'utilisation du paramètre `allow-unauthenticated`, les appels à la fonction sont publiques, car non authentifiés.
Ce paramètre ajoute le rôle `cloudfunctions.invoker` à `allUsers` et permet l'invocation de cette fonction sans authentification.
Cette permission se trouve dans l'onglet autorisations de votre Cloud Function.
Vous allez voir comment sécuriser l'appel à cette Cloud Function.

### Suppression du droit publique d'invocation

Supprimez le droit donné à tous le monde d'invoquer la fonction :

```bash
gcloud functions remove-iam-policy-binding "${MY_ID}-simple-http" --region=europe-west1 --member=allUsers --role=roles/cloudfunctions.invoker && sleep 30
```

**Notes :**

La propagation de cette modification peut prendre jusqu'à 30 secondes. D'où le `&& sleep 30` à la fin de cette commande. 🙈🙉🙊 Cela peut être +? Armez vous de patience pour la vérification suivante.

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

Afin d'authentifier votre requête HTTP, vous devez utiliser un token d'authentification. Pour plus de simplicité, vous allez l'exporter dans votre environnement :

```bash
export MY_TOKEN=$(gcloud auth print-identity-token)
```

Et avec `curl`, vous utilisez cette commande :

```bash
curl -H "Authorization: bearer ${MY_TOKEN}"  "${URL_SIMPLE_HTTP}?name=blabla"
```

Vous devriez avoir en retour `Hello blabla`

### Info +

- Ce token d'authentification a une durée de validité de 1H
- Votre appel à fonction avec l'authentification de votre compte a fonctionné car la permission `cloudfunctions.functions.invoke`
  vous a été accordée sur le projet `cloud-function-hands-on` via le rôle `cloudfunctions.invoker`.


## Les différentes méthodes HTTP

La fonction précédente peut répondre à toutes formes de requêtes HTTP avec un comportement similaire.
Vous allez modifier la fonction avec <walkthrough-editor-open-file filePath="cloud-function-hands-on/functions/simple-http-function/main.py">l'éditeur</walkthrough-editor-open-file>

### Exercice

**Objectifs :**

1. Répondre à une requête `GET` :

- avec ou sans argument, votre fonction vous répond `"OK, method GET"`
- vous utilisez la méthode `Response` du module `flask`, exemple :

```python
from flask import Response

Response(response="My message", status=201) # 201 HTTP status code 'Created'
```

2. Répondre à une requête `POST` :

- vous appelez la fonction avec un *JSON*, tel que :

 ```json
{
  "names": ["name1", "name2"]
}
```

- votre fonction doit vous répondre un *JSON*, tel que :

```json
{
  "messages": ["hello name1","hello name2"]
}
```

3. Répondre à une autre requête (`PUT`, `DELETE`... etc) :

- votre fonction doit répondre un code d'erreur `405` et la réponse de votre choix.

**Exemple de code :**

```python
from flask import Response

def handle_request(request):
    if request.method == 'GET':
        return Response(response="OK, method GET", status=200)
```

```python
def handle_request(request):
    payload_json:dict=request.get_json()
    return payload_json["names"]
```

```python
def handle_request(request):
    if request.method not in ('GET', 'POST'):
        print("Not Good")
```

**Important :**

Si vous avez des difficultés à écrire votre code, n'hésitez pas à nous solliciter

### Déploiement/Redéploiement de la Cloud Function

Pensez à redéployer votre Cloud Function HTTP via la commande de déploiement mais sans le paramètre `--allow-unauthenticated`

### Test de votre Cloud Function

GET

```bash
 curl -H "Authorization: bearer ${MY_TOKEN}" "${URL_SIMPLE_HTTP}?name=blabla"
```

retour attendu : `OK, method GET`

POST

```bash
 curl -X POST -H "Content-Type: application/json" -H "Authorization: bearer ${MY_TOKEN}" "${URL_SIMPLE_HTTP}" -d '{"names":["Olivier", "Ivan"]}'
```

retour attendu de cet exemple : `{"messages": ["hello Olivier","hello Ivan"]}`

Other (ex : HEAD)

```bash
 curl --head -H "Authorization: bearer ${MY_TOKEN}" "${URL_SIMPLE_HTTP}?name=blabla"
```

retour attendu : `"Not Good"` ou votre message personnalisé

## Cloud Function dans l'écosystème GCP

Vous venez d'apprendre à construire différents types de Cloud Function réagissant directement aux appels reçus.
Mais les fonctions ont aussi un usage plus étendu et peuvent interagir avec d'autres composants de votre infrastructure GCP,
situés souvent dans des zones privées.

Vous allez dans ce hands-on interroger une base redis contenant des informations essentielles avec une Cloud Function HTTP.

### Déploiement/Redéploiement de la Cloud Function v2

Déployez la function <walkthrough-editor-open-file filePath="cloud-function-hands-on/functions/redis-function/main.py">redis-function</walkthrough-editor-open-file>

Placer vous dans le dossier contenant le code de la Cloud Function :

```bash
cd ../redis-function/
```

Déployer la Cloud Function avec cette commande :

```bash
gcloud functions deploy "${MY_ID}-redis-function" --region=europe-west1 \
--runtime python310 --trigger-http --entry-point=handle_request --gen2
```

**Notes :**

- Le paramètre `gen2` permet de déployer une Cloud Function de seconde génération, plus performante.


### Test de la Cloud Function

Comme vu précédemment, récupérez l'URL de déclenchement par un appel API, mais le format a changé:

```bash
export URL_REDIS_HTTP=$(gcloud functions describe "${MY_ID}-redis-function" --region=europe-west1 --format="value(serviceConfig.uri)")
echo $URL_REDIS_HTTP
```
En effet, **Cloud Function Gen2** est déployé sur [Cloud Run](https://cloud.google.com/run/docs), c'est donc une URL **Cloud Run**.

```bash
curl -H "Authorization: bearer ${MY_TOKEN}"  "${URL_REDIS_HTTP}?id=${MY_ID}"
```

Vous devriez avoir en retour `Request failed`, ca fonctionne... Wait what ? 😨

Et oui, vous avez suivi les instructions à la lettre sans vous souciez du code !
Sinon vous auriez vu cette partie non fonctionnelle :

```python
REDIS_CLIENT = redis.Redis(host="my_redis_server",
                           port=6379,
                           password="my_redis_password")
```

Effectivement, vous devez récupérer les informations `host`, `port` et `password`.
Le `host`et `password` ont été au préalable stockés dans des secrets dans **GCP secret manager** et le `port` peut être configuré via une variable d'environnement simple.

### Intégration des secrets et des variables d'environnement.

Modifiez le fichier <walkthrough-editor-open-file filePath="cloud-function-hands-on/functions/redis-function/main.py">main.py</walkthrough-editor-open-file>

Ajoutez la récupération de variable d'environnement :

```python
import os

#env vars
REDIS_HOST = os.environ.get('REDIS_HOST')
REDIS_PORT = int(os.environ.get('REDIS_PORT'))
REDIS_PWD = os.environ.get('REDIS_PASSWORD')
```

et modifiez l'appel du client redis :

```python
REDIS_CLIENT = redis.Redis(host=REDIS_HOST,
                           port=REDIS_PORT,
                           password=REDIS_PWD)
```

Vous avez codé la récupération des variables d'environnement, vous pouvez maintenant les instancier lors du redéploiement de la fonction
grâce aux secrets `gcfn-handson-redis-secret` et `gcfn-handson-redis-host` ou directement :

```bash
gcloud functions deploy "${MY_ID}-redis-function" --region=europe-west1 \
--runtime python310 --trigger-http --entry-point=handle_request --gen2 \
--set-env-vars="REDIS_PORT=6379" --set-secrets "REDIS_PASSWORD=gcfn-handson-redis-secret:latest,REDIS_HOST=gcfn-handson-redis-host:latest"
```

**Notes :**

- le paramètre `set-env-vars` permet d'instancier une ou plusieurs variables d'environnement directement.
- le paramètre `set-secrets` permet aussi d'instancier ces variables en définissant un ou plusieurs stockages de secret ainsi que leur version respective.

### Test de la Cloud Function

```bash
curl -H "Authorization: bearer ${MY_TOKEN}"  "${URL_REDIS_HTTP}?id=${MY_ID}"
```

Vous devriez avoir en retour `upstream request timeout`, non toujours pas le bon résultat... 😤

Comme souvent avec le serverless, il n'y a pas de notion d'infrastructure avec une Cloud Function. Vous devez l'intégrer dans un VPC afin
qu'elle puisse communiquer avec des zones privées, donc le serveur **redis**.

### Intégration dans un VPC

**Notes :**

- Nous avons au préalable installer un `VPC access connecteur` pour que vos fonctions puissent s'intégrer à un VPC.
- La configuration de ce connecteur est disponible dans le [code terraform du hands-on](https://github.com/ibeauvais/cloud-function-hands-on/blob/main/infra/vpc.tf):

> Pour plus de [documentation](https://cloud.google.com/vpc/docs/serverless-vpc-access)

Redéployez votre function avec le connecteur VPC `gcfn-handson-connectors` :

```bash
gcloud functions deploy "${MY_ID}-redis-function" --region=europe-west1 \
--runtime python310 --trigger-http --entry-point=handle_request --gen2 \
--set-env-vars="REDIS_PORT=6379" --set-secrets "REDIS_PASSWORD=gcfn-handson-redis-secret:latest,REDIS_HOST=gcfn-handson-redis-host:latest" \
--vpc-connector=gcfn-handson-connectors
```

Refaite un test avec la commande `curl` :

```bash
curl -H "Authorization: bearer ${MY_TOKEN}"  "${URL_REDIS_HTTP}?id=${MY_ID}"
```

Maintenant vous obtenez un `secret`, que se passe-t-il si vous interrogez de nouveau le redis avec ce `secret` en tant que `id`?...

## Fin de l'aventure !

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

Mais beaucoup d'autres choses restent à découvrir...
Merci pour votre participation et rejoignons-nous pour les mots de la fin.



