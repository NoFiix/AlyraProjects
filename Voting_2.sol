// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable {

    enum WorkflowStatus { 
        RegisteringVoters, 
        ProposalsRegistrationStarted, 
        ProposalsRegistrationEnded, 
        VotingSessionStarted, 
        VotingSessionEnded, 
        VotesTallied }

    struct Voter { 
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId; }

    struct Proposal {
        string description;
        uint voteCount; 
        uint ProposalId; } //__\\ J'ai rajouté un ProposalId directement ici pour donner un identifiant à chaque vote 

// -------------------------------------------------------------------------------------------------
// Variable d'état --------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------
    uint public totalProposals ; // Donnera un ID à chaque propositions 
    uint public winningProposalId ; // Sera l'ID du gagnant
    address _addressWinner ; // Pour stocker l'address du winner
    uint maxVotes ; //__\\ Pour stocker le nombre de votes du gagnant

    WorkflowStatus public Status ;

    mapping(address => Voter) voters ;
    mapping(address => Proposal) public proposals ; //__\\ J'ai modifié la key du mapping de "uint" en "address"

    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    constructor() Ownable(msg.sender){  }

// -------------------------------------------------------------------------------------------------
// Fonctions whitelist, blacklist ---------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------

    function authorize (address _addr) public onlyOwner {
        voters [_addr].isRegistered = true ;
    }

    //__\\ On rajoute une fonction qui permet d'enlever l'autorisation de participer au propositions et votes
    function desauthorize (address _addr) public onlyOwner {
        require (voters[_addr].isRegistered == false, "cette addresse n'est deja pas autorise a participer") ;
        voters[_addr].isRegistered = false ;
    }

// -------------------------------------------------------------------------------------------------
// Propositions ---------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------

    function proposals_Activation () public onlyOwner { // seul le propriétaire du contrat peut activer la sessoin des propositions
        require (Status != WorkflowStatus.ProposalsRegistrationStarted, "Les propositions sont deja ouvertes") ;
        Status = WorkflowStatus.ProposalsRegistrationStarted ;
        emit WorkflowStatusChange (WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted) ; // je ne comprends pas l'utilite de ces event. Pourquoi en avoir besoin ?
        //isPropositionOpen = true ; 
    }
    function proposals_Desactivation () public onlyOwner { // le propriétaire du contrat peut désactiver la session des propositions
        require (Status != WorkflowStatus.ProposalsRegistrationEnded, "Les propositions sont deja ferme") ;
        Status = WorkflowStatus.ProposalsRegistrationEnded ;
        emit WorkflowStatusChange (WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded) ;
        //isPropositionOpen = false ;
    }

    function propositions (string memory voteText) public { // fonction pour enregistrer une proposition
        //require (isPropositionOpen, "Les propositions sont pour le moment ferme") ;
        require (Status == WorkflowStatus.ProposalsRegistrationStarted, "Les propositions sont pour le moment ferme") ;
        require (voters[msg.sender].isRegistered == true, "vous n etes pas autorise a effectuer cette action") ;
        
        totalProposals ++ ; // on incrémente le numéro de la proposition 
        proposals[msg.sender].description = voteText ; // puis on enregistre la proposition (commençant par 1, plus simple pour voter)
        voters[msg.sender].votedProposalId = totalProposals ; // puis on l'attribue au votant (commençant par 1)
        emit ProposalRegistered (totalProposals) ; // puis on emet l'event
    }

// -------------------------------------------------------------------------------------------------
// Votes -----------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------

    function vote_Activation () public onlyOwner { // l'Owner peut activer la session des votes
        require (Status != WorkflowStatus.VotingSessionStarted, "Les votes sont deja ouverts") ;
        Status = WorkflowStatus.VotingSessionStarted ;
        emit WorkflowStatusChange (WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted) ;
        //isVoteOpen = true ;
    }

    function vote_Desactivation () public onlyOwner { // l'Owner peut désactiver la session des votes
        require (Status != WorkflowStatus.VotingSessionEnded, "Les votes sont deja ferme") ;
        Status = WorkflowStatus.VotingSessionEnded ;
        emit WorkflowStatusChange (WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded) ;
        //isVoteOpen = false ;
    }

    function vote_Choice (address _addrProposition) public { // fonction pour voter pour une proposition
        Voter storage v = voters[msg.sender]; // vu que ça se répète souvent, autant en créer une variable 

        require (Status == WorkflowStatus.VotingSessionStarted, "Les votes sont pour le moment ferme") ;
        require (v.isRegistered == true, "vous n etes pas autorise a effectuer cette action") ;
        require (!v.hasVoted , "vous avez deja vote") ;

        v.hasVoted = true ;
        v.votedProposalId = proposals[_addrProposition].ProposalId ; //__\\ On va chercher l'ID via l'address
        proposals[_addrProposition].voteCount += 1 ;

        if (maxVotes < proposals[_addrProposition].voteCount) { //__\\ Si le nombre de votes de la proposition est supérieur au max actuel
                maxVotes = proposals[_addrProposition].voteCount ; //__\\ On met à jour le nombre max de votes
                _addressWinner = _addrProposition ; //__\\ Puis on met à jour l'address du gagnant
            }

        emit Voted (msg.sender , totalProposals);
    }

// -------------------------------------------------------------------------------------------------
// Décompte des votes ---------------------------------------------------------------
// -------------------------------------------------------------------------------------------------

    function number_of_Proposals () public view returns (uint) {
        return totalProposals ;
    }

// -------------------------------------------------------------------------------------------------
// Getter ------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------

    function getWinner () public view returns (address, uint, string memory) { // un getter pour récupérer le gagnant, l'id de la proposition, le nombre de vote et la proposition 
        require (winningProposalId == 0, "le gagnant a deja ete selectionne") ;
        require (Status == WorkflowStatus.VotingSessionEnded, "attention, les votes sont encore ouvert") ;

        return (_addressWinner, maxVotes, proposals[_addressWinner].description) ;
    }

}