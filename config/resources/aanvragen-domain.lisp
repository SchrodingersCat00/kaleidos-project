

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
              (document-container :via ,(s-prefix "dct:hasPart")
                        :as "documents"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/consultatie-antwoorden/")
  :features '(include-uri)
  :on-path "consultation-responses")

(define-resource consultation-response-code ()
  :class (s-prefix "ext:Consultatie-uitkomstCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote"))
                (:alt-label :string ,(s-prefix "skos:altLabel")))
  :has-many `((consultation-response :via ,(s-prefix "besluitvorming:uitkomst")
                                     :inverse t
                                     :as "consultation-responses"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/concept/consultatie-uitkomst-codes/")
  :features '(include-uri)
  :on-path "consultation-response-codes")

(define-resource translation-state-name ()
  :class (s-prefix "besluitvorming:VertalingsaanvraagStatusCode") ;; NOTE: Should be subclass of besluitvorming:Status (mu-cl-resources reasoner workaround)
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:alt-label :string ,(s-prefix "skos:altLabel")))
  :has-many `((translation-state :via ,(s-prefix "ext:vertalingsaanvraagStatusCode")
                                 :inverse t
                                 :as "translation-states"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/concept/vertalingsaanvraag-status-codes/")
  :features '(include-uri)
  :on-path "translation-state-code")
