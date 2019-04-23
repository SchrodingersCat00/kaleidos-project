alias Acl.Accessibility.Always, as: AlwaysAccessible
alias Acl.Accessibility.ByQuery, as: AccessByQuery
alias Acl.GraphSpec.Constraint.Resource.AllPredicates, as: AllPredicates
alias Acl.GraphSpec.Constraint.Resource.NoPredicates, as: NoPredicates
alias Acl.GraphSpec.Constraint.ResourceFormat, as: ResourceFormatConstraint
alias Acl.GraphSpec.Constraint.Resource, as: ResourceConstraint
alias Acl.GraphSpec, as: GraphSpec
alias Acl.GroupSpec, as: GroupSpec
alias Acl.GroupSpec.GraphCleanup, as: GraphCleanup

defmodule Acl.UserGroups.Config do
  defp access_by_role( group_string ) do
    %AccessByQuery{
      vars: ["session_group","session_role"],
      query: sparql_query_for_access_role( group_string ) }
  end

  defp sparql_query_for_access_role( group_string ) do
    "PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
    PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
    SELECT ?session_group ?session_role WHERE {
      <SESSION_ID> ext:sessionGroup/mu:uuid ?session_group;
                   ext:sessionRole ?session_role.
      FILTER( ?session_role = \"#{group_string}\" )
    }"
  end

  def user_groups do
    # These elements are walked from top to bottom.  Each of them may
    # alter the quads to which the current query applies.  Quads are
    # represented in three sections: current_source_quads,
    # removed_source_quads, new_quads.  The quads may be calculated in
    # many ways.  The useage of a GroupSpec and GraphCleanup are
    # common.
    [
      # // PUBLIC
      %GroupSpec{
        name: "public",
        useage: [:read],
        access: %AlwaysAccessible{}, # TODO: Should be only for logged in users
        graphs: [ %GraphSpec{
          graph: "http://mu.semte.ch/graphs/public",
          constraint: %ResourceConstraint{
            resource_types: [
              "http://mu.semte.ch/vocabularies/validation/Execution",
              "http://mu.semte.ch/vocabularies/validation/Validation",
              "http://mu.semte.ch/vocabularies/validation/Error",
              "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject",
              "http://dbpedia.org/ontology/Case",
              "http://mu.semte.ch/vocabularies/ext/DossierType",
              "http://mu.semte.ch/vocabularies/ext/DossierThema",
              "https://data.vlaanderen.be/ns/organisatie#Hoedanigheid",
              "http://mu.semte.ch/vocabularies/ext/BeleidsDomein",
              "http://mu.semte.ch/vocabularies/ext/Bevoegdheid",
              "https://data.vlaanderen.be/ns/besluitvorming#Zitting",
              "https://data.vlaanderen.be/ns/besluitvorming#Agenda",
              "https://data.vlaanderen.be/ns/besluitvorming#Opmerking",
              "http://mu.semte.ch/vocabularies/ext/SubCase",
              "https://data.vlaanderen.be/ns/besluitvorming#Besluit",
              "https://data.vlaanderen.be/ns/besluitvorming#KortBestek",
              "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject",
              "http://xmlns.com/foaf/0.1/Person",
              "http://xmlns.com/foaf/0.1/OnlineAccount"
            ]
          } },
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/public/",
            constraint: %ResourceConstraint{
              resource_types: [ "https://data.vlaanderen.be/ns/besluitvorming#AgendaPunt"],
              predicates: %AllPredicates{
                except: [
                  "http://mu.semte.ch/vocabularies/ext/record" 
                ] 
              } 
            } 
          },            
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/sessions",
            constraint: %ResourceFormatConstraint{
              resource_prefix: "http://mu.semte.ch/sessions/"
            } } ] },
      %GroupSpec{
        name: "public-wf",
        useage: [:write, :read_for_write],
        access: %AlwaysAccessible{}, # TODO: Should be only for logged in users
        graphs: [%GraphSpec{
          graph: "http://mu.semte.ch/graphs/public",
          constraint: %ResourceConstraint{
            resource_types: [
              "http://mu.semte.ch/vocabularies/validation/Execution",
              "http://mu.semte.ch/vocabularies/validation/Validation",
              "http://mu.semte.ch/vocabularies/validation/Error",
              "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject",
              "http://dbpedia.org/ontology/Case",
              "http://mu.semte.ch/vocabularies/ext/DossierType",
              "http://mu.semte.ch/vocabularies/ext/DossierThema",
              "https://data.vlaanderen.be/ns/organisatie#Hoedanigheid",
              "http://mu.semte.ch/vocabularies/ext/BeleidsDomein",
              "http://mu.semte.ch/vocabularies/ext/Bevoegdheid",
              "https://data.vlaanderen.be/ns/besluitvorming#Opmerking",
              "http://mu.semte.ch/vocabularies/ext/SubCase",
              "https://data.vlaanderen.be/ns/besluitvorming#Besluit",
              "https://data.vlaanderen.be/ns/besluitvorming#KortBestek",
              "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject",
              "http://xmlns.com/foaf/0.1/Person",
              "http://xmlns.com/foaf/0.1/OnlineAccount"
            ]
          } 
        },
        %GraphSpec{
            graph: "http://mu.semte.ch/graphs/public/",
            constraint: %ResourceConstraint{
              resource_types: [ "https://data.vlaanderen.be/ns/besluitvorming#Agenda"],
              predicates: %AllPredicates{
                except: [
                  "http://mu.semte.ch/vocabularies/ext/goedgekeurd" ] } } },
        %GraphSpec{
          graph: "http://mu.semte.ch/graphs/public/",
          constraint: %ResourceConstraint{
            resource_types: [ "https://data.vlaanderen.be/ns/besluitvorming#AgendaPunt"],
            predicates: %AllPredicates{
              except: [
                "http://mu.semte.ch/vocabularies/ext/record",
                "http://mu.semte.ch/vocabularies/ext/formallyOk"
              ] 
            } 
          } 
        }
        ] 
      },
      # // ORGANIZATION HAS POSSIBLY DUPLICATE USER DATA
      %GroupSpec{
        name: "org",
        useage: [:read],
        access: %AccessByQuery{
          vars: ["session_group"],
          query: "PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
                  PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
                  SELECT ?session_group ?session_role WHERE {
                    <SESSION_ID> ext:sessionGroup/mu:uuid ?session_group.
                    }" },
        graphs: [ %GraphSpec{
          graph: "http://mu.semte.ch/graphs/organizations/",
          constraint: %ResourceConstraint{
            resource_types: [
              "http://xmlns.com/foaf/0.1/Person",
              "http://xmlns.com/foaf/0.1/OnlineAccount",
              "http://www.w3.org/ns/adms#Identifier"
            ] } } ] },

      # // ORG-ADMIN
      %GroupSpec{
        name: "o-admin-all",
        useage: [:read, :write, :read_for_write],
        access: access_by_role( "Kanselarij-admin" ),
        graphs: [ %GraphSpec{
          graph: "http://mu.semte.ch/graphs/organizations/",
          constraint: %ResourceConstraint{
            resource_types: [
              "https://data.vlaanderen.be/ns/besluitvorming#Zitting",
              "https://data.vlaanderen.be/ns/besluitvorming#AgendaPunt",
              "https://data.vlaanderen.be/ns/besluitvorming#Agenda"
            ] } },
        ] 
      },

      # // USER HAS NO DATA
      # this was moved to org instead.
      # perhaps move some elements to public when needed for demo
      # purposes.


      # // CLEANUP
      #
      %GraphCleanup{
        originating_graph: "http://mu.semte.ch/application",
        useage: [:write],
        name: "clean"
      }
    ]
  end
end