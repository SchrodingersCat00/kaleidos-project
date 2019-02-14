(define-resource case ()
  :class (s-prefix "besluitvorming:Consultatievraag")
  :properties `((:created :datetime ,(s-prefix "dct:created")) ;; NOTE: Type should be :date instead?
                (:shortTitle :string ,(s-prefix "dct:alternative"))
                (:number :number ,(s-prefix "adms:identifier")) ;; NOTE: Type should be :number instead?
                (:title :string ,(s-prefix "dct:title")))
  :has-one `((case-type :via ,(s-prefix "dct:type")
                           :as "type"))
  :has-many `((remark :via ,(s-prefix "besluitvorming:opmerking")
                                      :as "opmerking") ;; NOTE: opmerkingEN would be more suitable?
              (theme :via ,(s-prefix "dct:subject")
                     :as "themes")
              ; (persoon :via ,(s-prefix "?") ;; heeftCreator?  ;; NOTE: used persoon instead of agent
              ;                                     :as "heeftCreator")
              (mandatee :via ,(s-prefix "besluitvorming:heeftBevoegde") ;; NOTE: used mandataris instead of agent
                        :as "mandatees")
              (person :via ,(s-prefix "besluitvorming:heeftIndiener") ;; NOTE: used persoon instead of agent
                      :as "creators")
              (person :via ,(s-prefix "besluitvorming:heeftContactpersoon") ;; NOTE: used persoon instead of agent
                      :as "contactPersons")
              (subcase :via ,(s-prefix "dct:hasPart")
                             :as "subcases")
              (case :via ,(s-prefix "dct:relation")
                       :as "related"))
  :resource-base (s-url "http://data.vlaanderen.be/id/Dossier/")
  :features '(include-uri)
  :on-path "cases")

(define-resource case-type ()
  :class (s-prefix "ext:DossierTypeCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :has-many `((case :via ,(s-prefix "dct:type")
                       :inverse t
                       :as "cases"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/DossierTypeCode/")
  :features '(include-uri)
  :on-path "case-types")


(define-resource subcase ()
  :class (s-prefix "dbpedia:UnitOfWork")
  :properties `((:shortTitle :string ,(s-prefix "dct:alternative"))
                (:title :string ,(s-prefix "dct:title"))
                (:confidentiality :string ,(s-prefix "dct:title")) ;; TODO:karel inconsisten with confidentiality earlier
                (:show-as-remark :boolean ,(s-prefix "ext:wordtGetoondAlsMededeling"))) ;; NOTE: supplementary addition to model
  :has-one `((decision :via ,(s-prefix "ext:besluitHeeftProcedurestap") ;; NOTE: instead of dct:hasPart (mu-cl-resources relation type checking workaround)
                      :as "decision")
             (case :via ,(s-prefix "dct:hasPart")
                     :inverse t
                     :as "case"))
  :has-many `((subcase-phase :via ,(s-prefix "ext:procedurestapFase")
                                   :as "phase")
              (confidentiality :via ,(s-prefix "besluitvorming:vertrouwelijkheid")
                               :as "confidentiality")
              (subcase :via ,(s-prefix "dct:relation")
                             :as "related-to")
              (document-version :via ,(s-prefix "ext:bevatDocumentversie") ;; NOTE: instead of dct:hasPart (mu-cl-resources relation type checking workaround)
                               :as "document-versions")
              (consulation-request :via ,(s-prefix "ext:bevatConsultatievraag") ;; NOTE: instead of dct:hasPart (mu-cl-resources relation type checking workaround)
                                   :as "consultationRequests") ;; NOTE: consultatieVRAGEN would be more suitable?
              (agendaitem :via ,(s-prefix "besluitvorming:isGeagendeerdVia")
                          :as "agendaitems")
              (meeting :via ,(s-prefix "besluitvorming:isAangevraagdVoor")
                       :as "requestedForMeetings")
              (remark :via ,(s-prefix "besluitvorming:opmerking") 
                      :as "remarks"))
  :resource-base (s-url "http://data.vlaanderen.be/id/Procedurestap/")
  :features '(include-uri)
  :on-path "subcases")

(define-resource subcase-phase () ;; NOTE: Should be subclass of besluitvorming:Status (mu-cl-resources reasoner workaround)
  :class (s-prefix "ext:ProcedurestapFase") ;; NOTE: as well as skos:Concept
  :properties `((:remark :string ,(s-prefix "rdfs:comment"))
                (:date :datetime ,(s-prefix "besluitvorming:statusdatum")))
  :has-many `((procedurestap :via ,(s-prefix "ext:procedurestapFase")
                          :inverse t
                          :as "subcases"))
  :has-one `((subcase-phase-code :via ,(s-prefix "ext:procedurestapFaseCode")
                       :as "code"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/ProcedurestapFase/")
  :features '(include-uri)
  :on-path "subcase-phases")

(define-resource subcase-phase-code ()
  :class (s-prefix "ext:ProcedurestapFaseCode") 
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :has-many `((subcase-phase :via ,(s-prefix "ext:procedurestapFaseCode")
                          :inverse t
                          :as "subcasephases")
              (subcase-phase-code :via ,(s-prefix "skos:broader") ;; NOTE: tree structure for type-hierarchy (cfr codelist) TODO:karel why model this?
                                        :inverse t
                                        :as "subphaseCodes"))
  :has-one `((subcase-phase-code :via ,(s-prefix "skos:broader")
                                      :as "superphase"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/ProcedurestapFaseCode/")
  :features '(include-uri)
  :on-path "subcase-phase-code")
  
(define-resource confidentiality ()
  :class (s-prefix "ext:VertrouwelijkheidCode") ;; NOTE: as well as skos:Concept
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/VertrouwelijkheidCode/")
  :features '(include-uri)
  :on-path "confidentialities")



(define-resource consultation-request ()
  :class (s-prefix "besluitvorming:Consultatievraag")
  :properties `((:request :string ,(s-prefix "besluitvorming:aanvraag"))
                (:date :datetime ,(s-prefix "besluitvorming:aanvraagdatum"))) ;; NOTE: Type should be :date instead?
  :has-one `((subcase :via ,(s-prefix "ext:bevatConsultatievraag")
                            :inverse t
                            :as "subcase")
             (consultation-type :via ,(s-prefix "dct:type")
                               :as "type")
             ; (??? :via ,(s-prefix "besluitvorming:isGesteldAan") ;; NOTE: shoudl be Agent? (mandataris/bestuursorgaan) TODO:karel
             ;                         :as "isGesteldAan")
             (person :via ,(s-prefix "besluitvorming:heeftContactpersoon") ;; NOTE: used persoon instead of agent
                     :as "contactPerson")
             (consultation-response :via ,(s-prefix "prov:generated") 
                                    :as "response"))
  :has-many `((remark :via ,(s-prefix "besluitvorming:opmerking") ;; NOTE: opmerkingEN would be more suitable?
                      :as "remarks"))
  :resource-base (s-url "http://data.vlaanderen.be/id/Consultatievraag/")
  :features '(include-uri)
  :on-path "consultation-requests")

(define-resource consultation-type ()
  :class (s-prefix "besluitvorming:Consultatietype")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :has-many `((consultation-request :via ,(s-prefix "dct:type")
                          :inverse t
                          :as "requests"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/ConsultatieTypeCode/")
  :features '(include-uri)
  :on-path "consultation-types")


(define-resource consultation-response ()
  :class (s-prefix "besluitvorming:Consultatie-antwoord")
  :properties `((:date :datetime ,(s-prefix "besluitvorming:ontvangstdatum")) ;; NOTE: Type should be :date instead?
                (:text :string ,(s-prefix "besluitvorming:samenvatting")))
  :has-one `((consultation-response-code :via ,(s-prefix "besluitvorming:uitkomst")
                                         :as "result")
             (consultation-request :via ,(s-prefix "prov:generated")
                                   :inverse t
                                   :as "consultation-request"))
  :has-many `((remark :via ,(s-prefix "besluitvorming:opmerking")
                      :as "remarks") 
              (document :via ,(s-prefix "dct:hasPart")
                        :as "documents"))
  :resource-base (s-url "http://data.vlaanderen.be/id/Consultatievraag/")
  :features '(include-uri)
  :on-path "consultation-responses")

(define-resource consultation-response-code ()
  :class (s-prefix "ext:Consultatie-uitkomstCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :has-many `((consultation-response :via ,(s-prefix "besluitvorming:uitkomst")
                                     :inverse t
                                     :as "consultation-responses"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/Consultatie-uitkomstCode/")
  :features '(include-uri)
  :on-path "consultation-response-codes")
