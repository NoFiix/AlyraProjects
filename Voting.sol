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
        uint voteCount; }

// -------------------------------------------------------------------------------------------------
// Variable d'état --------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------
    uint public proposalId ;
    uint public winningProposalId ;
    WorkflowStatus public Status ;
    mapping(address => Voter) voters ;
    mapping(uint => Proposal) public proposals ;

    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    constructor() Ownable(msg.sender){  }

// -------------------------------------------------------------------------------------------------
// Fonctions ---------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------

    function authorize (address _addr) public onlyOwner {
        voters [_addr].isRegistered = true ;
    }

// Partie sur les Propositions ---------------------------------------------------------------------

    function proposals_Activation () public onlyOwner {
        require (Status != WorkflowStatus.ProposalsRegistrationStarted, "Les propositions sont deja ouvertes") ;
        Status = WorkflowStatus.ProposalsRegistrationStarted ;
        emit WorkflowStatusChange (WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted) ; // je ne comprends pas l'utilite de ces event. Pourquoi en avoir besoin ?
        //isPropositionOpen = true ; 
    }
    function proposals_Desactivation () public onlyOwner {
        require (Status != WorkflowStatus.ProposalsRegistrationEnded, "Les propositions sont deja ferme") ;
        Status = WorkflowStatus.ProposalsRegistrationEnded ;
        emit WorkflowStatusChange (WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded) ;
        //isPropositionOpen = false ;
    }

    function propositions (string memory voteText) public {
        //require (isPropositionOpen, "Les propositions sont pour le moment ferme") ;
        require (Status == WorkflowStatus.ProposalsRegistrationStarted, "Les propositions sont pour le moment ferme") ;
        require (voters[msg.sender].isRegistered == true, "vous n etes pas autorise a effectuer cette action") ;
        
        proposalId ++ ; // on incrémente le numéro de la proposition 
        proposals[proposalId].description = voteText ; // puis on enregistre la proposition (commençant par 1, plus simple pour voter)
        voters[msg.sender].votedProposalId = proposalId ; // puis on l'attribue au votant (commençant par 1)
        emit ProposalRegistered (proposalId) ; // puis on emet l'event
    }

// Partie sur les Votes -----------------------------------------------------------------------------

    function vote_Activation () public onlyOwner {
        require (Status != WorkflowStatus.VotingSessionStarted, "Les votes sont deja ouverts") ;
        Status = WorkflowStatus.VotingSessionStarted ;
        emit WorkflowStatusChange (WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted) ;
        //isVoteOpen = true ;
    }

    function vote_Desactivation () public onlyOwner {
        require (Status != WorkflowStatus.VotingSessionEnded, "Les votes sont deja ferme") ;
        Status = WorkflowStatus.VotingSessionEnded ;
        emit WorkflowStatusChange (WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded) ;
        //isVoteOpen = false ;
    }

    function vote_Choice (uint _proposal_Choosen) public {
        Voter storage v = voters[msg.sender]; // vu que ça se répète souvent, autant en créer une variable 

        require (Status == WorkflowStatus.VotingSessionStarted, "Les votes sont pour le moment ferme") ;
        require (v.isRegistered == true, "vous n etes pas autorise a effectuer cette action") ;
        require (!v.hasVoted , "vous avez deja vote") ;

        v.hasVoted = true ;
        v.votedProposalId = _proposal_Choosen ;
        proposals[_proposal_Choosen].voteCount += 1 ;
        emit Voted (msg.sender , proposalId);
    }
 
    function number_of_Proposals () public view returns (uint) {
        return proposalId ;
    }

    function getWinner () public returns (uint, uint, string memory) {
        require (winningProposalId == 0, "le gagnant a deja ete selectionne") ;
        require (Status == WorkflowStatus.VotingSessionEnded, "attention, les votes sont encore ouvert") ;
        uint maxVotes = 0 ;

        for (uint i=0 ; i < proposalId ; i++) {
            if (maxVotes < proposals[i].voteCount) {
                maxVotes = proposals[i].voteCount ;
                winningProposalId = i ;
            }
        }
        return (winningProposalId, maxVotes, proposals[winningProposalId].description) ;
    }

}