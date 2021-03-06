(define-resource document-container ()
  :class (s-prefix "dossier:Serie")
  :properties `((:created               :datetime ,(s-prefix "dct:created")))
  :has-many `((remark                   :via ,(s-prefix "besluitvorming:opmerking")
                                        :as "remarks")
              (document                 :via ,(s-prefix "dossier:collectie.bestaatUit")
                                        :as "documents"))
  :has-one `((document-type             :via ,(s-prefix "ext:documentType")
                                        :as "type")
             (decision                  :via ,(s-prefix "ext:beslissingsfiche")
                                        :inverse t
                                        :as "signed-decision")
             (meeting-record            :via ,(s-prefix "ext:getekendeNotulen")
                                        :inverse t
                                        :as "signed-minutes"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/series/")
  :features '(include-uri)
  :on-path "documents") ;; TODO: change to "document-containers" once frontend fully migrated

(define-resource document ()
  :class (s-prefix "dossier:Stuk")
  :properties `((:name                 :string   ,(s-prefix "dct:title"))
                (:created               :datetime ,(s-prefix "dct:created"))
                (:modified              :datetime ,(s-prefix "dct:modified"))
                (:confidential          :boolean  ,(s-prefix "ext:vertrouwelijk")))
  :has-one `((access-level               :via ,(s-prefix "ext:toegangsniveauVoorDocumentVersie")
                                        :as "access-level")
            (file                       :via      ,(s-prefix "ext:file")
                                        :as "file")
            (file                       :via      ,(s-prefix "ext:convertedFile")
                                        :as "converted-file")
            (document-container         :via      ,(s-prefix "dossier:collectie.bestaatUit")
                                        :inverse t
                                        :as "document-container")
            (document                   :via      ,(s-prefix "pav:previousVersion")
                                        :as "previous-version")
            (document                   :via      ,(s-prefix "pav:previousVersion")
                                        :inverse t
                                        :as "next-version")
            (subcase                    :via ,(s-prefix "ext:bevatDocumentversie")
                                        :inverse t
                                        :as "subcase")
            (subcase                    :via ,(s-prefix "ext:bevatReedsBezorgdeDocumentversie")
                                        :inverse t
                                        :as "linked-subcase")
            (agendaitem                 :via ,(s-prefix "ext:bevatAgendapuntDocumentversie")
                                        :inverse t
                                        :as "agendaitem")
            (agendaitem                 :via ,(s-prefix "ext:bevatReedsBezorgdAgendapuntDocumentversie")
                                        :inverse t
                                        :as "agendaitem")
            (announcement               :via ,(s-prefix "ext:mededelingBevatDocumentversie")
                                        :inverse t
                                        :as "announcement")
            (newsletter-info            :via ,(s-prefix "ext:documentenVoorPublicatie")
                                        :inverse t
                                        :as "newsletter")
            (decision                   :via ,(s-prefix "ext:documentenVoorBeslissing")
                                        :inverse t
                                        :as "decision")
            (meeting-record             :via ,(s-prefix "ext:getekendeDocumentVersiesVoorNotulen")
                                        :inverse t
                                        :as "meeting-record")
            (meeting                    :via ,(s-prefix "ext:zittingDocumentversie")
                                        :inverse t
                                        :as "meeting")
                                        )
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/stukken/")
  :features `(include-uri)
  :on-path "document-versions") ;; TODO: change to "documents" once frontend fully migrated

(define-resource document-type ()
  :class (s-prefix "ext:DocumentTypeCode")
  :properties `((:label             :string ,(s-prefix "skos:prefLabel"))
                (:scope-note        :string ,(s-prefix "skos:scopeNote"))
                (:priority          :number ,(s-prefix "ext:prioriteit"))
                (:alt-label         :string ,(s-prefix "skos:altLabel")))
  :has-many `((document-container   :via    ,(s-prefix "ext:documentType")
                                    :inverse t
                                    :as "documents")
              (document-type        :via    ,(s-prefix "skos:broader")
                                    :inverse t
                                    :as "subtypes"))
  :has-one `((document-type         :via    ,(s-prefix "skos:broader")
                                    :as "supertype"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/concept/document-type-codes/")
  :features '(include-uri)
  :on-path "document-types")

