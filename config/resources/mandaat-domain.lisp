(define-resource birth ()
  :class (s-prefix "persoon:Geboorte")
  :properties `((:date :date ,(s-prefix "persoon:datum")))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/geboortes/")
  :features '(include-uri)
  :on-path "geboortes")

(define-resource mandate ()
  :class (s-prefix "mandaat:Mandaat")
  :properties `((:number-of-mandatees :number ,(s-prefix "mandaat:aantalHouders")))
  :has-one `((government-function :via ,(s-prefix "org:role")
                                  :as "function")
             (government-body :via ,(s-prefix "org:hasPost")
                                   :inverse t
                                   :as "bevat-in"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/mandaten/")
  :features '(include-uri)
  :on-path "mandates")

(define-resource mandatee ()
  :class (s-prefix "mandaat:Mandataris")
  :properties `((:priority        :number ,(s-prefix "mandaat:rangorde"))
                (:start           :datetime ,(s-prefix "mandaat:start"))
                (:end             :datetime ,(s-prefix "mandaat:einde"))
                (:date-sworn-in   :datetime ,(s-prefix "ext:datumEedaflegging"))
                (:date-decree     :datetime ,(s-prefix "ext:datumMinistrieelBesluit"))
                (:title           :string ,(s-prefix "dct:title")))
  :has-many `(
    ;; (mandatee                  :via ,(s-prefix "mandaat:isTijdelijkVervangenDoor")
    ;;                            :as "temporary-replacements")
             (ise-code            :via ,(s-prefix "ext:heeftBevoegdeMandataris")
                                  :as "ise-codes")
             (decision            :via ,(s-prefix "besluitvorming:neemtBesluit") ;; NOTE: What is the URI of property 'neemt' (Agent neemt besluit)? Guessed besluitvorming:neemtBesluit 
                                  :inverse t
                                  :as "decisions")
             (case                :via ,(s-prefix "besluitvorming:heeftBevoegde") ;; NOTE: used mandataris instead of agent
                                  :inverse t
                                  :as "cases")
             (meeting-record      :via ,(s-prefix "ext:aanwezigen")
                                  :as "meetings-attended")
             (approval            :via ,(s-prefix "ext:goedkeuringen")
                                  :as "approvals")
             (subcase             :via ,(s-prefix "besluitvorming:heeftBevoegde")
                                  :inverse t
                                  :as "subcases")
             (agendaitem          :via ,(s-prefix "besluitvorming:heeftBevoegdeVoorAgendapunt")
                                  :inverse t
                                  :as "agendaitems"))
  :has-one `((mandate             :via ,(s-prefix "org:holds")
                                  :as "holds")
             (person              :via ,(s-prefix "mandaat:isBestuurlijkeAliasVan")
                                  :as "person")
             (mandatee-state      :via ,(s-prefix "mandaat:status")
                                  :as "state"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/mandatarissen/")
  :features '(include-uri)
  :on-path "mandatees")

(define-resource mandatee-state ()
  :class (s-prefix "ext:MandatarisStatusCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote"))
                (:alt-label :string ,(s-prefix "skos:altLabel")))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/concept/mandataris-status-codes/")
  :features '(include-uri)
  :on-path "mandatee-states")

(define-resource government-domain () 
  :class (s-prefix "kans:Beleidsdomein")
  :properties `((:label           :string ,(s-prefix "skos:prefLabel"))
                (:scope-note      :string ,(s-prefix "skos:scopeNote"))
                (:alt-label       :string ,(s-prefix "skos:altLabel")))
  :has-many `((government-field   :via ,(s-prefix "ext:heeftBeleidsDomein")
                                  :inverse t
                                  :as "government-fields"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/concept/beleidsdomeinen/")
  :features '(include-uri)
  :on-path "government-domains")

(define-resource government-field () 
  :class (s-prefix "kans:Beleidsveld")
  :properties `((:label           :string ,(s-prefix "skos:prefLabel"))
                (:scope-note      :string ,(s-prefix "skos:scopeNote"))
                (:alt-label       :string ,(s-prefix "skos:altLabel")))
  :has-one `((ise-code            :via    ,(s-prefix "ext:heeftIseCode")
                                  :inverse t
                                  :as "ise-code")
            (government-domain    :via ,(s-prefix "ext:heeftBeleidsDomein")
                                  :as "domain"))                
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/concept/beleidsvelden/")
  :features '(include-uri)
  :on-path "government-fields")

(define-resource ise-code ()
  :class                                   (s-prefix "kans:IseCode")
  :properties `((:name            :string ,(s-prefix "skos:prefLabel"))
                (:code            :string ,(s-prefix "skos:altLabel")))
  :has-one `((government-field    :via    ,(s-prefix "ext:heeftIseCode")
                                  :as "field"))
  :has-many `((mandatee           :via ,(s-prefix "ext:heeftBevoegdeMandataris")
                                  :as "mandatees")
              (subcase            :via ,(s-prefix "ext:heeftInhoudelijkeStructuurElementen")
                                  :inverse t
                                  :as "subcases"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/concept/ise-codes/")
  :features `(no-pagination-defaults include-uri)
  :on-path "ise-codes")

(define-resource person ()
  :class (s-prefix "person:Person")
  :properties `((:last-name         :string ,(s-prefix "foaf:familyName"))
                (:alternative-name  :string ,(s-prefix "foaf:name"))
                (:first-name        :string ,(s-prefix "foaf:firstName")))
  :has-many `((mandatee             :via    ,(s-prefix "mandaat:isBestuurlijkeAliasVan")
                                    :inverse t
                                    :as "mandatees"))
  :has-one `((identification        :via    ,(s-prefix "ext:identifier")
                                    :as "identifier")
             (signature             :via    ,(s-prefix "ext:bevoegdePersoon")
                                    :inverse t
                                    :as "signature"))
             ;; (gender :via ,(s-prefix "persoon:geslacht")
             ;;         :as "gender")
             ;; (birth :via ,(s-prefix "persoon:heeftGeboorte")
             ;;      :as "birth")
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/personen/")
  :features '(include-uri)
  :on-path "people")

(define-resource gender ()
  :class (s-prefix "ext:GeslachtCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote"))
                (:alt-label :string ,(s-prefix "skos:altLabel")))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/concept/geslacht-codes/")
  :features '(include-uri)
  :on-path "genders")

(define-resource identification ()
  :class (s-prefix "adms:Identifier")
  :properties `((:id-name :string ,(s-prefix "skos:notation"))) ;; TODO: should have a specific type
  :has-one `((person :via ,(s-prefix "ext:identifier")
                     :inverse t
                     :as "personId"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/identificatoren/")
  :features '(include-uri)
  :on-path "identifications")

  (define-resource signature ()
  :class (s-prefix "ext:Handtekening")
  :properties `((:name      :string     ,(s-prefix "ext:zichtbareNaam"))
                (:function  :string     ,(s-prefix "ext:functie"))
                (:is-active :boolean    ,(s-prefix "ext:isStandaard")))
  :has-one `((person        :via        ,(s-prefix "ext:bevoegdePersoon")
                            :as "person")
             (file          :via        ,(s-prefix "ext:handtekening")
                            :as "file"))
  :has-many `((meeting      :via       ,(s-prefix "ext:heeftHandtekening")
                            :inverse t
                            :as "meetings"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/concept/signatures/")
  :features '(include-uri)
  :on-path "signatures")
