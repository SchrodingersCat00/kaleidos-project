(define-resource document ()
  :class (s-prefix "foaf:Document")
  :properties `((:archived :boolean ,(s-prefix "besluitvorming:gearchiveerd"))
                (:title :string ,(s-prefix "dct:title")) ;;string-set
                (:number-vp :string ,(s-prefix "besluitvorming:stuknummerVP")) ;; NOTE: What is the URI of property 'stuknummerVP'? Made up besluitvorming:stuknummerVP
                (:number-vr :string ,(s-prefix "besluitvorming:stuknummerVR"))) ;; NOTE: What is the URI of property 'stuknummerVR'? Made up besluitvorming:stuknummerVR
  :has-many `((remark :via ,(s-prefix "besluitvorming:opmerking")
                      :as "remarks") 
              (document-version :via ,(s-prefix "besluitvorming:heeftVersie")
                                :as "document-versions"))
  :has-one `((decision :via ,(s-prefix "ext:besluitHeeftDocument") ;; NOTE: Relation to document instad of document-subclass
                      :inverse t
                      :as "decision")
             (document-type :via ,(s-prefix "ext:documentType")
                       :as "type")
             (confidentiality :via ,(s-prefix "besluitvorming:vertrouwelijkheid")
                              :as "confidentiality"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/Document/")
  :features '(include-uri)
  :on-path "documents")

(define-resource document-version ()
  :class (s-prefix "ext:DocumentVersie")
  :properties `((:version-number        :string   ,(s-prefix "ext:versieNummer"))
                (:created               :datetime ,(s-prefix "ext:versieAangemaakt"))
                (:identification-number :string   ,(s-prefix "ext:idNumber"))
                (:serial-number         :string   ,(s-prefix "ext:serieNummer"))
                (:chosen-file-name      :string   ,(s-prefix "ext:gekozenDocumentNaam")))
  :has-one `((file                      :via      ,(s-prefix "ext:file")
                                        :as "file")
            (document                   :via      ,(s-prefix "ext:documentVersie")
                                        :inverse t
                                        :as "document")
            (subcase                    :via ,(s-prefix "ext:bevatDocumentversie")
                                        :inverse t
                                        :as "subcase"))
  :resource-base (s-url "http://localhost/vo/document-versions/")
  :features `(include-uri)
  :on-path "document-versions")

(define-resource document-type ()
  :class (s-prefix "ext:DocumentTypeCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :has-many `((document :via ,(s-prefix "ext:documentType")
                          :inverse t
                          :as "documenten")
              (document-type :via ,(s-prefix "skos:broader") ;; NOTE: tree structure for type-hierarchy (cfr codelist) TODO:karel do we need to model this?
                             :inverse t
                             :as "subtypes"))
  :has-one `((document-type :via ,(s-prefix "skos:broader")
                            :as "supertype"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/DocumentTypeCode/")
  :features '(include-uri)
  :on-path "document-types")


(define-resource translation-request ()
  :class (s-prefix "besluitvorming:Vertalingsaanvraag")
  :properties `((:target-language :string ,(s-prefix "besluitvorming:doeltaal"))
                (:expected-delivery-date :date ,(s-prefix "besluitvorming:verwachteOpleverdatum")))
  :has-many `(
              (document-version :via ,(s-prefix "prov:generated")
                                :as "documentVersions")
              (translation-state :via ,(s-prefix "ext:vertalingsaanvraagStatus")
                                  :as "states")
              (remark :via ,(s-prefix "besluitvorming:opmerking")
                      :as "remarks")) ;; NOTE: opmerkingEN would be more suitable?
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/Vertalingsaanvraag/")
  :features '(include-uri)
  :on-path "translation-requests")

(define-resource translation-state ()
  :class (s-prefix "besluitvorming:VertalingsaanvraagStatus") ;; NOTE: Should be subclass of besluitvorming:Status (mu-cl-resources reasoner workaround)
  :properties `((:date :datetime ,(s-prefix "besluitvorming:statusdatum"))
                (:value :uri ,(s-prefix "ext:vertalingsaanvraagStatusCode"))) ;; NOTE: Status-code as human-readable URI TODO:karel why a uri?
  :has-many `((remark :via ,(s-prefix "rdfs:comment")
                      :as "remarks"))
  :has-one `((translation-request :via ,(s-prefix "ext:vertalingsaanvraagStatus") ;; NOTE: More specific relationship then besluitvorming:status as mu-cl-resources workaround
                                 :inverse t
                                 :as "translationRequest"))
  :resource-base (s-url "http://data.vlaanderen.be/id/VertalingsaanvraagStatus/")
  :features '(include-uri)
  :on-path "translation-states")

;; TODO:karel not used
(define-resource media-type ()
  :class (s-prefix "ext:MediaTypeCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :has-many `((document-version :via ,(s-prefix "ext:documentversie")
                                :inverse t
                                :as "documentVersions"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/MediaTypeCode/")
  :features '(include-uri)
  :on-path "media-types")