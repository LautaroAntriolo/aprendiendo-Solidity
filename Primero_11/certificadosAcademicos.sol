// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AcademicCertificates {
    struct Certificate {
        string studentName;
        string courseName;
        uint256 issueDate;
        string grade;
        bool isValid;
        address issuer;
    }
    
    mapping(bytes32 => Certificate) public certificates;
    mapping(address => bool) public authorizedIssuers;
    
    // Eventos
    event CertificateIssued(bytes32 indexed certificateHash, string studentName, string courseName);
    event IssuerAuthorized(address indexed issuer);
    event IssuerRevoked(address indexed issuer);
    
    constructor() {
        authorizedIssuers[msg.sender] = true;
    }
    
    modifier soloUsuariosAutorizados() {
        require(authorizedIssuers[msg.sender], "Not authorized to issue certificates");
        _;
    }
    
    function authorizeIssuer(address issuer) public soloUsuariosAutorizados {
        authorizedIssuers[issuer] = true;
        emit IssuerAuthorized(issuer);
    }
    
    function revokeIssuer(address issuer) public soloUsuariosAutorizados {
        authorizedIssuers[issuer] = false;
        emit IssuerRevoked(issuer);
    }
    
    function issueCertificate(
        string memory studentName,
        string memory courseName,
        string memory grade,
        bytes32 certificateHash
    ) public soloUsuariosAutorizados {
        require(certificates[certificateHash].issueDate == 0, "Certificate already exists");
        
        certificates[certificateHash] = Certificate({
            studentName: studentName,
            courseName: courseName,
            issueDate: block.timestamp,
            grade: grade,
            isValid: true,
            issuer: msg.sender
        });
        
        emit CertificateIssued(certificateHash, studentName, courseName);
    }
    

    function verifyCertificate(bytes32 certificateHash) 
        public 
        view 
        returns (
            string memory studentName,
            string memory courseName,
            uint256 issueDate,
            string memory grade,
            bool isValid,
            address issuer
        ) 
    {
        Certificate memory cert = certificates[certificateHash];
        require(cert.issueDate != 0, "Certificate does not exist");
        
        return (
            cert.studentName,
            cert.courseName,
            cert.issueDate,
            cert.grade,
            cert.isValid,
            cert.issuer
        );
    }
    

    function revokeCertificate(bytes32 certificateHash) public soloUsuariosAutorizados {
        require(certificates[certificateHash].issueDate != 0, "Certificate does not exist");
        certificates[certificateHash].isValid = false;
    }
}