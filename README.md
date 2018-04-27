# San Francisco Crime Classification
Pour ce projet, nous avons réalisé 4 modèles :

	1. K Nearest Neighbors,
	2. Régression Logistique,
	3. Arbres de décision,
	4. Boosting (Gradient Boosting).

### K Nearest Neighbors
Nous avons utilisé le langage Python afin de paralléliser notre algorithme vue la grande taille des données, plus précisément nous avons utilisé le package scikit-learn (version 0.17) qu'est très connue par sa rapidité et son efficacité. Le jeu données utilisé a été travaillé en langage R vue sa maturité.

- la fonction "neighbors.KNeighborsClassifier" permet de faire appel au classifieur en précisant les paramètres suivants :
	- n_neighbors : le nombre de voisins qui représente le paramètre critique sur lequel repose la méthode KNN,
	- n_jobs : nombre de cœurs utilisés dans la parallélisation (si -1 tous les cœurs seront utilisés, sinon un entier),
	- weights : pondération des points par l'inverse de leur distance,
	- p : paramètre de la distance Minkowski, (p = 1 distance manathan, p = 2 distance euclidienne)

- la fonction "fit", met le modèle en œuvre en l'apprenant.

- predict_proba : fournit la probabilité d'appartenance à chaque catégorie.

### Régression Logistique
Ce script est réalisé en R et qui est composé de deux parties principales :

	- Organisation des données en créant de nouvelles variables,
	- Application du modèle.
#### Organisation des données
Dans un premier temps, nous créerons les variables dont nous utiliserons pour la régression logistique. La fonction "make_vars_date" extrait toutes les informations nécessaires du champ "Date" dans le jeu de données, en extrayant l'année, mois, heure et jour du mois. Concernant la fonction "make_training_factors" permet d'organiser toutes les informations nécessaires dans une table de données R (data frame).

#### Application du modèle
L'utilisation de la régression logistique est très simple en R avec le package "Liblinear" (package développé en C). Il suffit juste d'appeler la fonction Liblinear et préciser que le résultat sera sous la forme de probabilités.

### Arbre de décision
Pour la réalisation de ce code, nous avons utilisé la même démarche que pour la régression logistique (organisation et application). L'organisation des données suit le même principe en utilisant les fonctions mais dans un ordre différent. Concernant l'application du modèle, nous avons utilisé le package "rpart" pour l'implémentation des arbres de décision. La fonction "predict" permet de faire la prédiction après l'apprentissage du modèle.

### Boosting
Nous avons utilisé le package "xgboost" pour appliquer un "gradient boosting" et aussi le package "data.table" qu'est une structure de données qui hérite de "data.frame" et elle est plus rapide dans le traitement de données grâce à son développemet en langage C.

L'organisation et extraction de données suit le même principe. La différence réside dans la rotation des variables X et Y grâce à une analyse en composantes principales en utilisant la fonction "preProcess" qu'on l'a utilisé aussi pour normaliser aussi les deux variables. Les paramètres utilisés sont expliqués en détails dans le rapport joint.
