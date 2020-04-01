
reshape wide confirmed confirmed_rate deaths recovered pop date, i(elapsed) j(country)
list confirmed1 confirmed2 confirmed3 in -5/l, abbreviate(13)

** LABELLING

* Antigua
rename confirmed1   atg_c
rename deaths1      atg_d
rename recovered1   atg_r
rename date1        atg_date
label var atg_c "ATG cases"
label var atg_d "ATG deaths"
label var atg_r "ATG recovered"
label var atg_date "ATG case date"

* Bahamas
rename confirmed2   bhs_c
rename deaths2      bhs_d
rename recovered2   bhs_r
rename date2        bhs_date
label var bhs_c "BHS cases"
label var bhs_d "BHS deaths"
label var bhs_r "BHS recovered"
label var bhs_date "BHS case date"

* Barbados 
rename confirmed3   brb_c
rename deaths3      brb_d
rename recovered3   brb_r
rename date3        brb_date
label var brb_c "BRB cases"
label var brb_d "BRB deaths"
label var brb_r "BRB recovered"
label var brb_date "BRB case date"

* Belize
rename confirmed4   blz_c
rename deaths4      blz_d
rename recovered4   blz_r
rename date4        blz_date
label var blz_c "BLZ cases"
label var blz_d "BLZ deaths"
label var blz_r "BLZ recovered"
label var blz_date "BLZ case date"

* Cuba
rename confirmed5   cub_c
rename deaths5      cub_d
rename recovered5   cub_r
rename date5        cub_date
label var cub_c "CUB cases"
label var cub_d "CUB deaths"
label var cub_r "CUB recovered"
label var cub_date "CUB case date"

* Dominica
rename confirmed6   dma_c
rename deaths6      dma_d
rename recovered6   dma_r
rename date6        dma_date
label var dma_c "DMA cases"
label var dma_d "DMA deaths"
label var dma_r "DMA recovered"
label var dma_date "DMA case date"

* Dominican Republic
rename confirmed7   dom_c
rename deaths7      dom_d
rename recovered7   dom_r
rename date7        dom_date
label var dom_c "DOM cases"
label var dom_d "DOM deaths"
label var dom_r "DOM recovered"
label var dom_date "DOM case date"

* Grenada
rename confirmed8   grd_c
rename deaths8      grd_d
rename recovered8   grd_r
rename date8        grd_date
label var grd_c "GRD cases"
label var grd_d "GRD deaths"
label var grd_r "GRD recovered"
label var grd_date "GRD case date"

* Guyana
rename confirmed9   guy_c
rename deaths9      guy_d
rename recovered9   guy_r
rename date9        guy_date
label var guy_c "GUY cases"
label var guy_d "GUY deaths"
label var guy_r "GUY recovered"
label var guy_date "GUY case date"

* Haiti
rename confirmed10   hti_c
rename deaths10      hti_d
rename recovered10   hti_r
rename date10        hti_date
label var hti_c "HTI cases"
label var hti_d "HTI deaths"
label var hti_r "HTI recovered"
label var hti_date "HTI case date"

* Jamaica
rename confirmed11   jam_c
rename deaths11      jam_d
rename recovered11   jam_r
rename date11        jam_date
label var jam_c "JAM cases"
label var jam_d "JAM deaths"
label var jam_r "JAM recovered"
label var jam_date "JAM case date"

* St Kitts and Nevis
rename confirmed12   kna_c
rename deaths12      kna_d
rename recovered12   kna_r
rename date12        kna_date
label var kna_c "KNA cases"
label var kna_d "KNA deaths"
label var kna_r "KNA recovered"
label var kna_date "KNA case date"

* St Lucia
rename confirmed13   lca_c
rename deaths13      lca_d
rename recovered13   lca_r
rename date13        lca_date
label var lca_c "LCA cases"
label var lca_d "LCA deaths"
label var lca_r "LCA recovered"
label var lca_date "LCA case date"

* St Vincent
rename confirmed14   vct_c
rename deaths14      vct_d
rename recovered14   vct_r
rename date14        vct_date
label var vct_c "VCT cases"
label var vct_d "VCT deaths"
label var vct_r "VCT recovered"
label var vct_date "VCT case date"

* Singapore
rename confirmed15   sgp_c
rename deaths15      sgp_d
rename recovered15   sgp_r
rename date15        sgp_date
label var sgp_c "SGP cases"
label var sgp_d "SGP deaths"
label var sgp_r "SGP recovered"
label var sgp_date "SGP case date"

* South Korea
rename confirmed16   kor_c
rename deaths16      kor_d
rename recovered16   kor_r
rename date16        kor_date
label var kor_c "KOR cases"
label var kor_d "KOR deaths"
label var kor_r "KOR recovered"
label var kor_date "KOR case date"

* Suriname 
rename confirmed17   sur_c
rename deaths17      sur_d
rename recovered17   sur_r
rename date17        sur_date
label var sur_c "SUR cases"
label var sur_d "SUR deaths"
label var sur_r "SUR recovered"
label var sur_date "SUR case date"

* Trinidad and Tobago
rename confirmed18   tto_c
rename deaths18      tto_d
rename recovered18   tto_r
rename date18        tto_date
label var tto_c "TTO cases"
label var tto_d "TTO deaths"
label var tto_r "TTO recovered"
label var tto_date "TTO case date"

* UK
rename confirmed19   gbr_c
rename deaths19      gbr_d
rename recovered19   gbr_r
rename date19        gbr_date
label var gbr_c "GBR cases"
label var gbr_d "GBR deaths"
label var gbr_r "GBR recovered"
label var gbr_date "GBR case date"

* US
rename confirmed20   usa_c
rename deaths20      usa_d
rename recovered20   usa_r
rename date20        usa_date
label var usa_c "USA cases"
label var usa_d "USA deaths"
label var usa_r "USA recovered"
label var usa_date "USA case date"

