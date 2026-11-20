# Prévision 2026 : note de conjoncture de l'Insee du 10 septembre 2026 (figure 8, annexe statistique).
# Revenu disponible hors SIFIM +1,5 % ; revenus de la propriété hors SIFIM +2,0 % ;
# prix de la consommation hors SIFIM +2,0 % ; pouvoir d'achat -0,4 % pour l'ensemble des ménages
# et -0,7 % par unité de consommation (d'où la croissance des unités de consommation).
# Les revenus de la propriété hors SIFIM de 2026 sont supposés évoluer comme ceux de la note (+2,0 %),
# sur la base des revenus nets de 2025.

prevision_2026 <- function(d) {
  d25 <- d[d$annee == 2025, ]
  uc_2026 <- (1 - 0.004) / (1 - 0.007)
  hors <- (d25$rdb_hors_sifim * 1.015 - d25$propriete_nette_hors_sifim * 1.020) /
    (d25$rdb_hors_sifim - d25$propriete_nette_hors_sifim) / 1.020 / uc_2026
  data.frame(annee = 2026,
             pa_officiel = d25$pa_officiel * (1 - 0.007),
             pa_hors_propriete = d25$pa_hors_propriete * hors)
}
