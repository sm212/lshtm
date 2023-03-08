library(dplyr)

df = haven::read_dta('assignment_23 (1).dta')

baseline = data.frame(id = unique(df$id), time = 0) |>
  left_join(df) %>%
  select(id, baseline = pro)

tidyr::complete(df, id, time) %>%
  group_by(id) %>%
  tidyr::fill(treat, sex) %>% 
  left_join(baseline, by = 'id') %>%
  haven::write_dta('assignment_full2.dta')
