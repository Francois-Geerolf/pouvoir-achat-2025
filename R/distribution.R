# Comptes nationaux distribués 2023 (Insee Analyses n° 119, André et Renaud, avril 2026) :
# part des revenus financiers dans le revenu disponible par dixième de niveau de vie (figure 1a)
# et évolution du pouvoir d'achat par unité de consommation par cinquième en 2023 (figure 4b).

library(readxl)

f <- tempfile(fileext = ".xlsx")
download.file("https://www.insee.fr/fr/statistiques/fichier/8973957/ia119.xlsx", f, mode = "wb", quiet = TRUE)

figure <- function(onglet, ligne) {
  x <- read_xlsx(f, sheet = onglet, col_names = FALSE, .name_repair = "minimal")
  entetes <- unlist(x[3, ])
  i <- grep(ligne, x[[1]])[1]
  j <- which(!is.na(entetes))[-1]   # la première colonne est le libellé
  setNames(as.numeric(unlist(x[i, j])), entetes[j])
}

rdb <- figure("Figure 1a", "^Revenu disponible brut \\(S14\\)")
financiers <- figure("Figure 1a", "^Revenus financiers")
cat("Revenus financiers par UC, 2023 (euros) :\n"); print(financiers)
cat("\nPart des revenus financiers dans le revenu disponible brut, 2023 (%) :\n")
print(round(100 * financiers / rdb, 1))
cat("[texte : moins de 3 % pour le cinquième dixième (D5), près de 19 % pour les 10 % les plus aisés (D10), 7,4 % en moyenne]\n")

pa <- figure("Figure 4b", "^Pouvoir d'achat")
cat("\nPouvoir d'achat du RDB par UC en 2023, par cinquième de niveau de vie (%) :\n"); print(round(pa, 1))
cat("[texte : -4,6 / 0,0 / -0,5 / +0,8 / +2,2 ; +0,3 en moyenne]\n")
