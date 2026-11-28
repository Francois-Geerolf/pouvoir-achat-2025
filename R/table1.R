# Tableau 1 : pouvoir d'achat par unité de consommation, avec et sans les revenus de la propriété,
# évolutions annuelles en %, 2019-2026 (2026 : prévision de l'Insee, septembre 2026).
# Version publiée sur le blog de l'IFE-OFCE (25 novembre 2026).

library(gt)

source("R/donnees.R")
source("R/prevision2026.R")

series <- rbind(donnees[, c("annee", "pa_officiel", "pa_hors_propriete")], prevision_2026(donnees))
croissance <- function(x) 100 * (x / c(NA, x[-length(x)]) - 1)
series$officiel <- croissance(series$pa_officiel)
series$hors <- croissance(series$pa_hors_propriete)

# Contrôle : la mesure tous revenus recalculée coïncide avec celle publiée par l'Insee
controle <- merge(series, donnees[, c("annee", "pa_uc_officiel")])
stopifnot(all(abs(controle$officiel - controle$pa_uc_officiel)[controle$annee >= 2000] < 0.05))

t1 <- series[series$annee >= 2019, c("annee", "officiel", "hors")]
t1[, -1] <- round(t1[, -1], 1) + 0   # évite un « -0,0 » pour 2023
print(t1)

# Données du tableau (deux décimales), lues par l'article
dir.create("csv", showWarnings = FALSE)
write.csv(data.frame(annee = series$annee[series$annee >= 2019],
                     tous_revenus = round(series$officiel[series$annee >= 2019], 2),
                     hors_revenus_propriete = round(series$hors[series$annee >= 2019], 2)),
          "csv/table1.csv", row.names = FALSE)

# Format du blog : signe explicite, virgule décimale, signe moins typographique, 0,0 sans signe
format_taux <- function(x) {
  s <- formatC(abs(x), format = "f", digits = 1, decimal.mark = ",")
  ifelse(x > 0, paste0("+", s), ifelse(x < 0, paste0("−", s), s))
}

table1 <- data.frame(Mesure = c("Tous revenus", "Hors revenus de la propriété"),
                     rbind(format_taux(t1$officiel), format_taux(t1$hors)))
names(table1)[-1] <- as.character(t1$annee)

table1 <- table1 |>
  gt() |>
  cols_label(Mesure = "En %", `2026` = html("2026<sup>p</sup>")) |>
  cols_align(align = "center", columns = -1) |>
  tab_source_note(html("Note : <sup>p</sup> prévision de l'Insee (septembre 2026) ; hors revenus de la propriété, calcul de l'auteur à partir de cette prévision.")) |>
  tab_source_note("Sources : Insee, comptes nationaux annuels, base 2020, et note de conjoncture de septembre 2026 (pour 2026) ; Eurostat (nasa_10_nf_tr) ; calculs de l'auteur.")

gtsave(table1, filename = "png/table1.png")
gtsave(table1, filename = "pdf/table1.pdf")
