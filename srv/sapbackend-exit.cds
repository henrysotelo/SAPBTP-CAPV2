using { sapbackend as external } from './external/sapbackend.csn';
define service SAPBackendExit{
    @cds.cloud.sdk.http.client
    @cds.persistence : {
        table,
        skip: false
    }
    @cds.autoexpose
    entity Incidents as select from external.IncidentsSet;
}