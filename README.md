# Le pouvoir d'achat en 2025, et ce qu'il révèle de l'indicateur

Date de publication : novembre 2026.

Ce dépôt met à disposition des codes de réplication pour l'[article en lien](https://fgeerolf.com/pouvoir-achat-2025.html).

<p align="center">

  <!-- Reader Navigation -->
  **[📖 Lire en ligne](https://fgeerolf.com/pouvoir-achat-2025.html)** •
  **[📄 Version PDF](https://fgeerolf.com/pouvoir-achat-2025.pdf)** •
  **[🌐 Présentation HTML](https://fgeerolf.com/pouvoir-achat-2025-handouts.html)** •
  **[📓 Présentation PDF](https://fgeerolf.com/pouvoir-achat-2025-slides.pdf)**

</p>

## Réplication

Les scripts s'exécutent depuis la racine du dépôt (ouvrir `pouvoir-achat-2025.Rproj`). Ils téléchargent directement les données de l'Insee et d'Eurostat : il n'y a rien à installer d'autre que les paquets R (`readxl`, `ggplot2`, `scales`, `gt`).

[`R/donnees.R`](R/donnees.R), appelé par les autres scripts, rassemble les données et les écrit dans `data.csv` :

- Eurostat, comptes non financiers des ménages, `nasa_10_nf_tr` (secteur S14, France) : revenu disponible brut, revenus de la propriété, intérêts avant et après répartition des SIFIM (`D41G`, `D41`) ;
- Insee, comptes nationaux annuels, base 2020 (mai 2026), dépense de consommation des ménages par produit aux niveaux les plus fins : consommation de SIFIM (« services financiers de prêts et dépôts implicitement mesurés ») en valeur et en volume, qui donne le prix de la consommation hors SIFIM ;
- Insee, pouvoir d'achat du revenu disponible brut et nombre d'unités de consommation.

Le pouvoir d'achat hors revenus de la propriété est le revenu disponible hors SIFIM, diminué des revenus nets de la propriété effectivement reçus (intérêts hors SIFIM, dividendes, revenus de l'assurance-vie, loyers des terrains), déflaté par le prix de la consommation hors SIFIM et rapporté au nombre d'unités de consommation. La prévision pour 2026 reprend celle de la note de conjoncture de l'Insee de septembre 2026 ([`R/prevision2026.R`](R/prevision2026.R)).

### Tableau 1 : Pouvoir d'achat par unité de consommation, avec et sans les revenus de la propriété

[Code R](R/table1.R)

![Tableau 1](png/table1.png)

### Figure 1 : Pouvoir d'achat par unité de consommation, avec et sans les revenus de la propriété, base 100 en 2019

[Code R](R/figure1.R)

![Figure 1](png/figure1.png)

### Chiffres cités dans le texte

[Code R](R/chiffres.R) : cumuls 2021-2023 et 2021-2025, revenus de la propriété et intérêts hors SIFIM, dividendes, variante sans neutraliser les SIFIM, comparaison sur longue période depuis 2000. Chaque chiffre est affiché à côté de la valeur retenue dans le texte.

[Code R](R/distribution.R) : comptes nationaux distribués 2023 (*Insee Analyses* n° 119, avril 2026), part des revenus financiers dans le revenu disponible par dixième de niveau de vie et pouvoir d'achat par cinquième.

## Millésime des données

Les chiffres de l'article correspondent aux comptes annuels de l'Insee publiés en mai 2026 (2023 définitif, 2024 semi-définitif, 2025 provisoire) et aux données d'Eurostat de novembre 2026. Les publications ultérieures peuvent modifier légèrement les résultats.
