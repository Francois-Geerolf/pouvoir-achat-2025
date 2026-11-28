# Téléchargement des données utilisées dans « Pouvoir d'achat : ce que masquent les revenus du patrimoine »
# Usage : source("R/donnees.R") depuis la racine du dépôt (les autres scripts le font).
# Crée le data.frame `donnees` (une ligne par année, 1999-2025, montants en milliards d'euros)
# et l'écrit dans data.csv.

library(readxl)

telecharger <- function(url, ext) {
  f <- tempfile(fileext = ext)
  download.file(url, f, mode = "wb", quiet = TRUE)
  f
}

annees <- 1999:2025

# ---- 1. Eurostat, comptes non financiers des ménages (S14), France -------------------------
# nasa_10_nf_tr : revenu disponible brut (B6G) et revenus de la propriété (D4),
# avec les intérêts avant répartition des SIFIM (D41G), c'est-à-dire effectivement versés et reçus.

url_eurostat <- paste0("https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/nasa_10_nf_tr/",
                       "A.CP_MEUR..B6G+D41+D41G+D42+D43+D44+D45.S14.FR/?format=SDMX-CSV&startPeriod=1999")
nf <- read.csv(telecharger(url_eurostat, ".csv"))

eurostat <- function(item, sens) {
  z <- nf[nf$na_item == item & nf$direct == sens, ]
  setNames(z$OBS_VALUE, z$TIME_PERIOD)[as.character(annees)] / 1000
}

# ---- 2. Insee, dépense de consommation des ménages par produit (comptes annuels, mai 2026) --
# Niveaux diffusables les plus fins : la ligne 138G_K64S donne la consommation de
# « services financiers de prêts et dépôts (implicitement mesurés) », c'est-à-dire les SIFIM.

f_conso <- telecharger("https://www.insee.fr/fr/statistiques/fichier/8988813/T_CONSO_EFF_PRODUITS_MENAGES_fr.xlsx", ".xlsx")

conso <- function(onglet, code, libelle = NULL) {
  x <- read_xlsx(f_conso, sheet = onglet, col_names = FALSE, .name_repair = "minimal")
  ans <- suppressWarnings(as.numeric(unlist(x[4, ])))
  i <- which(x[[1]] == code)
  if (!is.null(libelle)) i <- i[grepl(libelle, x[[2]][i])]
  i <- i[length(i)]
  setNames(as.numeric(unlist(x[i, !is.na(ans)])), ans[!is.na(ans)])[as.character(annees)] / 1000
}

# ---- 3. Insee, pouvoir d'achat et unités de consommation (comptes annuels, mai 2026) --------

f_pa <- telecharger("https://www.insee.fr/fr/statistiques/fichier/2830244/econ-gen-revenu-dispo-pouv-achat-2.xlsx", ".xlsx")
pa <- read_xlsx(f_pa, sheet = 1, skip = 3)
ans_pa <- as.numeric(substr(names(pa)[-1], 1, 4))

insee_pa <- function(motif) {
  i <- grep(motif, pa[[1]])[1]
  setNames(as.numeric(unlist(pa[i, -1])), ans_pa)[as.character(annees)]
}

# ---- Assemblage ----------------------------------------------------------------------------

donnees <- data.frame(
  annee = annees,
  rdb = eurostat("B6G", "PAID"),
  interets_recus = eurostat("D41", "RECV"),
  interets_recus_hors_sifim = eurostat("D41G", "RECV"),
  interets_verses = eurostat("D41", "PAID"),
  interets_verses_hors_sifim = eurostat("D41G", "PAID"),
  dividendes = eurostat("D42", "RECV"),
  benefices_reinvestis = eurostat("D43", "RECV"),
  assurance_vie = eurostat("D44", "RECV"),
  loyers_terrains_recus = eurostat("D45", "RECV"),
  loyers_terrains_verses = eurostat("D45", "PAID"),
  conso = conso("MEURcour", "P31", "individuelle des m"),
  conso_volume = conso("MEUR2020", "P31", "individuelle des m"),
  sifim = conso("MEURcour", "138G_K64S"),
  sifim_volume = conso("MEUR2020", "138G_K64S"),
  uc_croissance = insee_pa("unités de consommation$|Nombre d'unités"),
  pa_uc_officiel = insee_pa("^Pouvoir d'achat par unité de consommation")
)

# Revenus de la propriété effectivement reçus et versés (hors SIFIM)
donnees$propriete_recus_hors_sifim <- with(donnees, interets_recus_hors_sifim + dividendes +
                                             benefices_reinvestis + assurance_vie + loyers_terrains_recus)
donnees$propriete_verses_hors_sifim <- with(donnees, interets_verses_hors_sifim + loyers_terrains_verses)
donnees$propriete_nette_hors_sifim <- with(donnees, propriete_recus_hors_sifim - propriete_verses_hors_sifim)

# Revenu disponible et prix de la consommation hors SIFIM
donnees$rdb_hors_sifim <- with(donnees, rdb - sifim)
donnees$deflateur <- with(donnees, conso / conso_volume)
donnees$deflateur_hors_sifim <- with(donnees, (conso - sifim) / (conso_volume - sifim_volume))

# Indice des unités de consommation (1999 = 1)
donnees$uc <- cumprod(c(1, 1 + donnees$uc_croissance[-1] / 100))

# Pouvoir d'achat par unité de consommation, en niveau
donnees$pa_officiel <- with(donnees, rdb / deflateur / uc)
donnees$pa_hors_propriete <- with(donnees, (rdb_hors_sifim - propriete_nette_hors_sifim) / deflateur_hors_sifim / uc)

write.csv(donnees, "data.csv", row.names = FALSE)
