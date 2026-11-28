# Chiffres cités dans le texte de « Pouvoir d'achat : ce que masquent les revenus du patrimoine »
# (blog de l'IFE-OFCE, 25 novembre 2026), dans l'ordre du texte.
# Chaque ligne affiche le chiffre recalculé, puis entre crochets la valeur retenue dans le texte.

source("R/donnees.R")
source("R/prevision2026.R")

d <- donnees
v <- function(col, an) d[[col]][d$annee == an]
pct <- function(a, b) 100 * (a / b - 1)
fr <- function(x, k = 1) formatC(x, format = "f", digits = k, decimal.mark = ",")
ligne <- function(libelle, valeur, texte) cat(sprintf("%-78s %10s   [texte : %s]\n", libelle, valeur, texte))
p26 <- prevision_2026(d)

cat("\n== Introduction ==\n")
ligne("2025, hors revenus de la propriété (%)",
      fr(pct(v("pa_hors_propriete", 2025), v("pa_hors_propriete", 2024))), "+0,3")

cat("\n== Ce qui s'est passé en 2025 (hors SIFIM) ==\n")
ligne("2025 : revenus nets de la propriété hors SIFIM (%)",
      fr(pct(v("propriete_nette_hors_sifim", 2025), v("propriete_nette_hors_sifim", 2024))),
      "-12,8 (note de conjoncture, tableau 8)")
ligne("Intérêts effectivement reçus (hors SIFIM), 2021 et 2024 (Md€)",
      paste(fr(v("interets_recus_hors_sifim", 2021), 0), "et", fr(v("interets_recus_hors_sifim", 2024), 0)), "« triplent »")
ligne("Revenus de la propriété reçus hors SIFIM, 2021-2024 (%)",
      fr(pct(v("propriete_recus_hors_sifim", 2024), v("propriete_recus_hors_sifim", 2021)), 0), "+50")
ligne("Revenu disponible hors SIFIM, 2021-2024 (%)",
      fr(pct(v("rdb_hors_sifim", 2024), v("rdb_hors_sifim", 2021))), "+17,5")

cat("\n== Une explication qui vaut pour toute la période ==\n")
autres <- function(an) v("rdb_hors_sifim", an) - v("propriete_nette_hors_sifim", an)
for (an in 2022:2023)
  ligne(paste(an, ": revenus nets de la propriété / reste du revenu (%)"),
        paste(fr(pct(v("propriete_nette_hors_sifim", an), v("propriete_nette_hors_sifim", an - 1)), 0), "/",
              fr(pct(autres(an), autres(an - 1)))),
        c("2022" = "+17 ; trois à quatre fois plus vite", "2023" = "+18 ; trois à quatre fois plus vite")[as.character(an)])
for (an in 2022:2023)
  ligne(paste0(an, ", hors revenus de la propriété (%)"),
        fr(pct(v("pa_hors_propriete", an), v("pa_hors_propriete", an - 1))), c("2022" = "-0,9", "2023" = "0,0")[as.character(an)])
ligne("2021-2023, hors revenus de la propriété / tous revenus (%)",
      paste(fr(pct(v("pa_hors_propriete", 2023), v("pa_hors_propriete", 2021))), "/",
            fr(pct(v("pa_officiel", 2023), v("pa_officiel", 2021)))), "-0,9 / +0,1")
ligne("2026 (prévision), tous revenus / hors revenus de la propriété (%)",
      paste(fr(pct(p26$pa_officiel, v("pa_officiel", 2025))), "/",
            fr(pct(p26$pa_hors_propriete, v("pa_hors_propriete", 2025)))), "-0,7 / -0,8")

cat("\n== Note : variante sans neutraliser les SIFIM (revenus nets de la propriété publiés, déflateur de la consommation) ==\n")
brut <- with(d, (rdb - (interets_recus + dividendes + benefices_reinvestis + assurance_vie + loyers_terrains_recus) +
                   (interets_verses + loyers_terrains_verses)) / deflateur / uc)
for (an in 2022:2023)
  ligne(paste(an, "(%)"), fr(pct(brut[d$annee == an], brut[d$annee == an - 1])), c("2022" = "-0,7", "2023" = "+0,1")[as.character(an)])

cat("\n== Ce que l'épisode révèle de l'indicateur : dividendes perçus par les ménages (D42) ==\n")
ligne("2012-2013 / 2017-2018 (%)",
      paste(fr(pct(v("dividendes", 2013), v("dividendes", 2012)), 0), "/",
            fr(pct(v("dividendes", 2018), v("dividendes", 2017)), 0)), "« d'un tiers » / « d'un tiers »")

cat("\n== Conclusion : 2019-2026 ==\n")
cumul <- function(col, p) c(pct(p[[col]], v(col, 2019)), 100 * ((p[[col]] / v(col, 2019))^(1 / 7) - 1))
h <- cumul("pa_hors_propriete", p26); o <- cumul("pa_officiel", p26)
ligne("Hors revenus de la propriété : cumul / par an (%)", paste(fr(h[1]), "/", fr(h[2])), "+2,0 / 0,3")
ligne("Tous revenus : cumul (%)", fr(o[1]), "+3,4")
