@IsTest
global class GoogleDriveHttpMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        
        // Mock for folder creation
        if (req.getMethod() == 'POST') {
            res.setStatusCode(201);
            res.setBody('{"id": "mockFolderId123"}');
            return res;
        }
        // Mock for folder retrieval
        else if (req.getMethod() == 'GET') {
            res.setStatusCode(200);
            res.setBody('{"items": [{"id": "mockFolderId123", "title": "Test Folder"}]}');
            return res;
        }
        
        // Default error response
        res.setStatusCode(400);
        res.setBody('{"error": "Bad Request"}');
        return res;
    }
}