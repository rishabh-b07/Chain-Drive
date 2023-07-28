pragma solidity ^0.8.0;

contract CollaborativeEditing {
    // Struct for representing a document
    struct Document {
        bytes content;
        address[] editors;
        mapping(address => bool) hasAccess;
    }

    // Mapping of document IDs to documents
    mapping(bytes32 => Document) documents;

    // Event for notifying when a new document is created
    event DocumentCreated(bytes32 documentId, address creator);

    // Function for creating a new document
    function createDocument(bytes32 documentId, bytes memory content) public {
        // Ensure that the document ID is not already in use
        require(documents[documentId].content.length == 0, "Document already exists");

        // Add the creator as an editor with full access
        Document storage document = documents[documentId];
        document.content = content;
        document.editors.push(msg.sender);
        document.hasAccess[msg.sender] = true;

        // Notify that the document was created
        emit DocumentCreated(documentId, msg.sender);
    }

    // Function for adding an editor to a document
    function addEditor(bytes32 documentId, address editor) public {
        // Ensure that the editor has not already been added
        Document storage document = documents[documentId];
        require(!document.hasAccess[editor], "Editor already has access");

        // Add the editor with read-write access
        document.editors.push(editor);
        document.hasAccess[editor] = true;
    }

    // Function for removing an editor from a document
    function removeEditor(bytes32 documentId, address editor) public {
        // Ensure that the editor has been added
        Document storage document = documents[documentId];
        require(document.hasAccess[editor], "Editor does not have access");

        // Remove the editor and revoke their access
        uint256 editorIndex;
        for (uint256 i = 0; i < document.editors.length; i++) {
            if (document.editors[i] == editor) {
                editorIndex = i;
                break;
            }
        }
        for (uint256 i = editorIndex; i < document.editors.length - 1; i++) {
            document.editors[i] = document.editors[i + 1];
        }
        document.editors.pop();
        document.hasAccess[editor] = false;
    }

    // Function for updating the content of a document
    function updateContent(bytes32 documentId, bytes memory content) public {
        // Ensure that the sender has access to edit the document
        Document storage document = documents[documentId];
        require(document.hasAccess[msg.sender], "Sender does not have access");

        // Update the content of the document
        document.content = content;
    }

    // Function for getting the content of a document
    function getContent(bytes32 documentId) public view returns (bytes memory) {
        // Ensure that the sender has access to view the document
        Document storage document = documents[documentId];
        require(document.hasAccess[msg.sender], "Sender does not have access");

        // Return the content of the document
        return document.content;
    }

    // Function for getting the editors of a document
    function getEditors(bytes32 documentId) public view returns (address[] memory) {
        // Ensure that the sender has access to view the document
        Document storage document = documents[documentId];
        require(document.hasAccess[msg.sender], "Sender does not have access");

        // Return the editors of the document
        return document.editors;
    }

}