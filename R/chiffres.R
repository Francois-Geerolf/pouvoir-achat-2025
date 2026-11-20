# Chiffres cités dans le texte de « Le pouvoir d'achat en 2025, et ce qu'il révèle de l'indicateur »
# Chaque ligne affiche le chiffre recalculé, puis entre crochets la valeur retenue dans le texte.

source("R/donnees.R")
source("R/prevision2026.R")

d <- donnees
v <- function(col, an) d[[col]][d$annee == an]
pct <- function(a, b) 100 * (a / b - 1)
fr <- function(x, k = 1) formatC(x, format = "f", digits = k, decimal.mark = ",")
ligne <- function(libelle, valeur, texte) cat(sprintf("%-78s %10s   [texte : %s]\n", libelle, valeur, texte))

cat("\n== Pouvoir d'achat par unité de consommation, cumuls ==\n")
ligne("2021-2023, hors revenus de la propriété / mesure officielle (%)",
      paste(fr(pct(v("pa_hors_propriete", 2023), v("pa_hors_propriete", 2021))), "/",
            fr(pct(v("pa_officiel", 2023), v("pa_officiel", 2021)))), "-0,9 / +0,1")
ligne("2021-2025, hors revenus de la propriété / mesure officielle (%)",
      paste(fr(pct(v("pa_hors_propriete", 2025), v("pa_hors_propriete", 2021))), "/",
            fr(pct(v("pa_officiel", 2025), v("pa_officiel", 2021)))), "+0,8 / +1,6")
p26 <- prevision_2026(d)
ligne("2026 (prévision), hors revenus de la propriété (%)",
      fr(pct(p26$pa_hors_propriete, v("pa_hors_propriete", 2025))), "-0,8")

cat("\n== Revenus de la propriété (hors SIFIM) ==\n")
autres <- function(an) v("rdb_hors_sifim", an) - v("propriete_nette_hors_sifim", an)
for (an in 2022:2023)
  ligne(paste(an, ": revenus nets de la propriété / reste du revenu (%)"),
        paste(fr(pct(v("propriete_nette_hors_sifim", an), v("propriete_nette_hors_sifim", an - 1)), 0), "/",
              fr(pct(autres(an), autres(an - 1)))), c("2022" = "+17", "2023" = "+18")[as.character(an)])
ligne("Intérêts reçus dans les comptes (avec SIFIM), 2021 et 2024 (Md€)",
      paste(fr(v("interets_recus", 2021), 0), "et", fr(v("interets_recus", 2024), 0)), "8 et 72")
ligne("Intérêts effectivement reçus (hors SIFIM), 2021 et 2024 (Md€)",
      paste(fr(v("interets_recus_hors_sifim", 2021), 0), "et", fr(v("interets_recus_hors_sifim", 2024), 0)), "11 et 34 ; « triplent »")
ligne("Revenus de l'assurance-vie, 2021-2024 (%)",
      fr(pct(v("assurance_vie", 2024), v("assurance_vie", 2021)), 0), "« plus de moitié »")
ligne("Revenus de la propriété reçus hors SIFIM, 2021-2024 (%)",
      fr(pct(v("propriete_recus_hors_sifim", 2024), v("propriete_recus_hors_sifim", 2021)), 0), "« de moitié »")
ligne("Revenu disponible hors SIFIM, 2021-2024 (%)",
      fr(pct(v("rdb_hors_sifim", 2024), v("rdb_hors_sifim", 2021))), "+17,5")
ligne("2025 : revenus nets de la propriété hors SIFIM (%)",
      fr(pct(v("propriete_nette_hors_sifim", 2025), v("propriete_nette_hors_sifim", 2024))), "-12,8 (note de conjoncture)")

cat("\n== Dividendes perçus par les ménages (D42) ==\n")
ligne("2012-2013 / 2017-2018 (%)",
      paste(fr(pct(v("dividendes", 2013), v("dividendes", 2012)), 0), "/",
            fr(pct(v("dividendes", 2018), v("dividendes", 2017)), 0)), "-34 / +32")

cat("\n== Variante sans neutraliser les SIFIM (revenus nets de la propriété publiés, déflateur officiel) ==\n")
brut <- with(d, (rdb - (interets_recus + dividendes + benefices_reinvestis + assurance_vie + loyers_terrains_recus) +
                   (interets_verses + loyers_terrains_verses)) / deflateur / uc)
for (an in 2022:2023)
  ligne(paste(an, "(%)"), fr(pct(brut[d$annee == an], brut[d$annee == an - 1])), c("2022" = "-0,7", "2023" = "+0,1")[as.character(an)])

cat("\n== Longue période, base 100 en 2000 ==\n")
i_off <- 100 * d$pa_officiel / v("pa_officiel", 2000)
i_hors <- 100 * d$pa_hors_propriete / v("pa_hors_propriete", 2000)
ecart <- setNames(i_hors - i_off, d$annee)
ligne("2000-2021, mesure officielle / hors revenus de la propriété (%)",
      paste(fr(i_off[d$annee == 2021] - 100), "/", fr(i_hors[d$annee == 2021] - 100)), "environ 20 %")
ligne("Écart (hors - officielle) en 2008, en points", fr(ecart["2008"]), "-1,1")
ligne("Écart maximal 2013-2020, en points", fr(max(ecart[as.character(2013:2020)])), "+1,6")
ligne("Écart en 2024, en points", fr(ecart["2024"]), "-1,9")
ligne("Plus grand écart en valeur absolue depuis 2000 (année)", names(which.max(abs(ecart[as.character(2000:2025)]))), "2024")
