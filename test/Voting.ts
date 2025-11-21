import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("Voting", function () {

  let voting, owner, voter1, voter2, voter3, voter4;

  beforeEach(async function (){
    [owner, voter1, voter2, voter3, voter4] = await ethers.getSigners();
    const Voting = await ethers.getContractFactory("Voting");
    voting = await Voting.deploy();
    await voting.waitForDeployment();
  });



// ::::::::::::: GETTERS ::::::::::::: //

  it("getVoter function should return a voters information for registered voter", async function () {
    // 1. Enregistrer le votant
    await voting.connect(owner).addVoter(voter1.address);
    // 2. Récupérer les infos (voter1 doit appeler car onlyVoters)
    const voterInfo = await voting.connect(voter1).getVoter(voter1.address);
    // 3. Vérifier
    expect(voterInfo.isRegistered).to.be.true;
    expect(voterInfo.hasVoted).to.be.false;
    expect(voterInfo.votedProposalId).to.equal(0);
  });

  it("getOneProposal function should return proposals informations for an id", async function () {
    // 1. Ajouter le votant
    await voting.connect(owner).addVoter(voter1.address);
    // 2. Démarrer la session d'enregistrement des propositions
    await voting.connect(owner).startProposalsRegistering();
    // 3. Maintenant vous pouvez ajouter une proposition
    await voting.connect(voter1).addProposal("Hello");
    // 4. Récupérer et vérifier
    const proposalInfo = await voting.connect(voter1).getOneProposal(1);
    expect(proposalInfo.description).to.equal("Hello");
    expect(proposalInfo.voteCount).to.equal(0);
  });

  it("Should revert if non-voter use the getVoter function", async function () {
    await voting.connect(owner).addVoter(voter1.address);
    await expect (voting.connect(owner).getVoter(voter1.address)
    ).to.be.revertedWith("You're not a voter");
  })

  it("Should revert if non-voter use the getOneProposal function", async function () {
    // 1. Ajouter voter1
    await voting.connect(owner).addVoter(voter1.address);
    
    // 2. Démarrer l'enregistrement des propositions
    await voting.connect(owner).startProposalsRegistering();
    
    // 3. voter1 ajoute une proposition
    await voting.connect(voter1).addProposal("Proposition1");
    
    // 4. Vérifier que voter1 PEUT récupérer la proposition
    const proposal = await voting.connect(voter1).getOneProposal(1); // ID 1 car 0 = GENESIS
    expect(proposal.description).to.equal("Proposition1");
    expect(proposal.voteCount).to.equal(0);
    
    // 5. Vérifier qu'un autre user (non-voter) NE PEUT PAS récupérer la proposition
    await expect(voting.connect(owner).getOneProposal(1)
    ).to.be.revertedWith("You're not a voter");
  });



// ::::::::::::: REGISTRATION ::::::::::::: // 

  it("Should revert if non-owner uses addVoter function", async function () {
    await expect(voting.connect(voter1).addVoter(voter1.address)
    ).to.be.revertedWithCustomError(voting, "OwnableUnauthorizedAccount")
    .withArgs(voter1.address);
  });

  it("Should emit the VoterRegistered event when calling the addVoter function", async function () {
    await expect(voting.addVoter(voter1)).to.emit(voting, "VoterRegistered").withArgs(voter1);
  });



// ::::::::::::: PROPOSAL ::::::::::::: // 



// ::::::::::::: VOTE ::::::::::::: //



// ::::::::::::: STATE ::::::::::::: //

  it("Should revert if non-owner uses startProposalsRegistering function", async function () {
    await expect(voting.connect(voter1).startProposalsRegistering()
    ).to.be.revertedWithCustomError(voting, "OwnableUnauthorizedAccount")
    .withArgs(voter1.address);
  });



// ::::::::::::: THE WINNER IS ::::::::::::: //
  













/*
  it("The sum of the Increment events should match the current value", async function () {
    const deploymentBlockNumber = await ethers.provider.getBlockNumber();

    // run a series of increments
    for (let i = 1; i <= 10; i++) {
      await counter.incBy(i);
    }

    const events = await counter.queryFilter(
      counter.filters.Increment(),
      deploymentBlockNumber,
      "latest",
    );

    // check that the aggregated events match the current value
    let total = 0n;
    for (const event of events) {
      total += event.args.by;
    }

    expect(await counter.x()).to.equal(total);
  });
  */


});


