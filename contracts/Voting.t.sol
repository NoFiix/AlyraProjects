// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "../contracts/Voting.sol";
import "hardhat/console.sol";

contract VotingTest {

    Voting voting ;

    function setUp() public {
        voting = new Voting();
    }

    // :::::::::: Owner :::::::::: //


    // :::::::::: WorkflowStatus initialisation :::::::::: //

    function test_InitialWorkflowStatus() public view {
        uint actual = uint(voting.workflowStatus());
        uint expected = uint(Voting.WorkflowStatus.RegisteringVoters);
        //console.log (actual, expected);
        require(actual == expected, "Initial status must be RegisteringVoters");    }

    // :::::::::: WorkflowStatus Change :::::::::: //

    function test_WorkflowStatus_ProposalsRegistrationStarted() public {
        voting.startProposalsRegistering();

        uint actual = uint(voting.workflowStatus());
        uint expected = uint(Voting.WorkflowStatus.ProposalsRegistrationStarted);
        //console.log (actual, expected);
        require(actual == expected, "Current status must be RegistrationStarted");    }

    function test_WorkflowStatus_ProposalsRegistrationEnded() public {
        voting.startProposalsRegistering();
        voting.endProposalsRegistering();

        uint actual = uint(voting.workflowStatus());
        uint expected = uint(Voting.WorkflowStatus.ProposalsRegistrationEnded);
        //console.log (actual, expected);
        require(actual == expected, "Current status must be RegistrationEnded");    }

    function test_WorkflowStatus_VotingSessionStarted() public {
        voting.startProposalsRegistering();
        voting.endProposalsRegistering();
        voting.startVotingSession();

        uint actual = uint(voting.workflowStatus());
        uint expected = uint(Voting.WorkflowStatus.VotingSessionStarted);
        //console.log (actual, expected);
        require(actual == expected, "Current status must be VotingStarted");    }

    function test_WorkflowStatus_VotingSessionEnded() public {
        voting.startProposalsRegistering();
        voting.endProposalsRegistering();
        voting.startVotingSession();
        voting.endVotingSession();

        uint actual = uint(voting.workflowStatus());
        uint expected = uint(Voting.WorkflowStatus.VotingSessionEnded);
        //console.log (actual, expected);
        require(actual == expected, "Current status must be VotingEnded");    }
    
    function test_WorkflowStatus_VotesTallied() public {
        voting.startProposalsRegistering();
        voting.endProposalsRegistering();
        voting.startVotingSession();
        voting.endVotingSession();
        voting.tallyVotes();

        uint actual = uint(voting.workflowStatus());
        uint expected = uint(Voting.WorkflowStatus.VotesTallied);
        //console.log (actual, expected);
        require(actual == expected, "Current status must be VotesTallied");    }
    
    // :::::::::: test_proposalsArray() :::::::::: //

    function test_ProposalGenesisAdded() public {
        voting.addVoter(address(this)); // Add a voter so test is allowed to call getters later
        voting.startProposalsRegistering(); // Start proposals registration phase
        require(keccak256(abi.encode(voting.getOneProposal(0).description)) == keccak256(abi.encode("GENESIS")), 
                "GENESIS proposal must be created automatically"); // Now "GENESIS" proposal should exist
        require(voting.getOneProposal(0).voteCount == 0, "GENESIS proposaldmust exist at index 0"); // and the number of votes should be 0
    }

    

    




    /*

    // :::::::::: addVoter :::::::::: //

    function test_OwnerCanAddVoter() public {
        address voter = address(1); // On définit une adresse à whitelist
        voting.addVoter(voter); // Owner (address(this)) ajoute voter
        require(voting.getVoter(voter).isRegistered == true,"Voter should be registered by owner"); // On vérifie que le votant est bien enregistré
    }


    // :::::::::: addProposal :::::::::: //

    function test_RegisteredVoterCanProposal() public {
        address voter = address (1) ;
        voting.addVoter(voter) ;
        voting.startProposalsRegistering();
        
        (bool success, bytes memory data) = address(voting).call(abi.encodeWithSignature("addProposal(string)", "HELLO")); // On simule le message sender = voter
        require(success, "Registered voter should be able to add a proposal");
    }

    // :::::::::: addProposal :::::::::: //

    function test_Revert_addProposal_ifNotRegistrationStarted() public {
        address voter = address(1);
        voting.addVoter(voter);

        voting.startProposalsRegistering();
        voting.endProposalsRegistering(); // workflow now OK

        // Call addProposal in the wrong state
        (bool success,) = address(voting).call(
            abi.encodeWithSignature("addProposal(string)", "HELLO")
        );

        require(!success, "Should revert: not in ProposalsRegistrationStarted state");
    }

    */



    // :::::::::: setVote :::::::::: //

    // :::::::::: setVote :::::::::: //

    // :::::::::: tallyVotes :::::::::: //

    // :::::::::: transitions :::::::::: //

    // :::::::::: interdits :::::::::: //

    // :::::::::: getVoter :::::::::: //

    // :::::::::: getOneProposal :::::::::: //

}