/**
 * ListMyProjects.message is machine-readable JSON only so the agent can map names without inventing text.
 * projectNames stays as List<String> for the invocable contract.
 */
public without sharing class TimeTrackingProjectService {
    public class Request {
        @InvocableVariable
        public String actingUserId;
    }

    public class Response {
        @InvocableVariable
        public List<String> projectNames;

        @InvocableVariable
        public String message;
    }

    @InvocableMethod(
        label='List My Projects'
        description='List project names assigned to the submitting user'
    )
    public static List<Response> listMyProjects(List<Request> requests) {
        List<Response> responses = new List<Response>();
        if (requests == null || requests.isEmpty()) {
            responses.add(buildResponse(null));
            return responses;
        }

        for (Request req : requests) {
            String actingUserId = resolveActingUserId(
                req == null ? null : req.actingUserId
            );
            responses.add(buildResponse(actingUserId));
        }
        return responses;
    }

    private static String resolveActingUserId(String actingUserId) {
        if (!String.isBlank(actingUserId) && looksLikeUserId(actingUserId)) {
            return actingUserId;
        }

        return null;
    }

    private static Boolean looksLikeUserId(String value) {
        return !String.isBlank(value) &&
            (value.length() == 15 || value.length() == 18) &&
            value.startsWith('005');
    }

    private static Response buildResponse(String actingUserId) {
        Response res = new Response();
        res.projectNames = new List<String>();

        if (String.isBlank(actingUserId)) {
            res.message = ':information_source: I need your Salesforce User Id (005...) in currentRecordId to list assigned projects.';
            return res;
        }

        List<Project_Assignment__c> assignments = [
            SELECT Project__r.Name, Project__c
            FROM Project_Assignment__c
            WHERE Assigned_User__c = :actingUserId
            ORDER BY LastModifiedDate DESC
        ];

        Set<String> uniqueNames = new Set<String>();
        for (Project_Assignment__c assignment : assignments) {
            if (assignment.Project__r != null && !String.isBlank(assignment.Project__r.Name)) {
                uniqueNames.add(assignment.Project__r.Name);
            } else if (assignment.Project__c != null) {
                uniqueNames.add(String.valueOf(assignment.Project__c));
            }
        }

        res.projectNames.addAll(uniqueNames);
        res.projectNames.sort();

        if (res.projectNames.isEmpty()) {
            res.message = JSON.serialize(
                new Map<String, Object>{
                    'source' => 'TimeTrackingProjectService',
                    'actingUserId' => actingUserId,
                    'projects' => new List<String>()
                }
            );
            return res;
        }

        res.message = JSON.serialize(
            new Map<String, Object>{
                'source' => 'TimeTrackingProjectService',
                'actingUserId' => actingUserId,
                'projects' => res.projectNames
            }
        );
        return res;
    }
}