using { sapbackend as external } from './external/sapbackend.csn';

define service SAPBackendExit{
    entity Incidents as select from external.IncidentsSet{
        IncidenceId,
        EmployeeId
    };
}