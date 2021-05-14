# LOG680 2.3 Exemple de persistance

## fetch.sh
Dans ce fichier, vous trouverez toute la logique de consommation d'API et d'ajout à la base de données.

## Base de données
Dans ce cas-ci, j'utilise une instance PostgreSQL hosté par [Elephantsql](https://www.elephantsql.com/).

Elephantsql a une offre complètement gratuit pour un accès à une instance très peu performante (l'instance n'a pas besoin d'être puissante pour 2.3).

## Github Actions
Pour exécuter le script comme cronjob j'utilise un workflow GitHub Actions avec un trigger de type "schedule".

## Cron
Notre workflow utilise un trigger qui accepte une notation utilisé par les cronjobs.

Vous pouvez créer votre cron expression facilement avec ce site web: https://crontab.guru/

