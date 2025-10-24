// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title RentalContractFactory
 * @notice Contrat principal pour gérer l'enregistrement et les mises à jour de tous les baux ImmobilX.
 * Utilise l'ID du contrat de la base de données (dbContractId) comme clé unique.
 */
contract RentalContractFactory {

    // ----------------------------------------------------
    // STRUCTURES DE DONNÉES
    // ----------------------------------------------------

    // Structure pour refléter les données d'un contrat de location
    struct RentalContract {
        uint256 dbContractId;    // ID du contrat dans votre DB AdonisJS (clé unique)
        uint256 landlordId;      // ID du bailleur (DB)
        uint256 tenantId;        // ID du locataire (DB)
        uint256 rentAmount;      // Montant du loyer (en plus petite unité)
        uint64 endDate;          // Date de fin (Timestamp Unix en secondes)
        string currentStatus;    // Ex: "pending", "active", "terminated"
        string depositStatus;    // Ex: "unpaid", "paid", "returned"
    }

    // Associe l'ID de la DB du contrat (clé) à la structure du bail (valeur)
    mapping(uint256 => RentalContract) public contracts;

    // L'administrateur du système (celui qui déploie le contrat)
    address immutable public owner;

    // ----------------------------------------------------
    // ÉVÉNEMENTS
    // ----------------------------------------------------

    event LeaseCreated(uint256 dbContractId, address indexed creator);
    event StatusUpdated(uint256 dbContractId, string newStatus);
    event EndDateUpdated(uint256 dbContractId, uint64 newEndDate);

    // ----------------------------------------------------
    // CONSTRUCTEUR
    // ----------------------------------------------------

    constructor() {
        owner = msg.sender;
    }

    // ----------------------------------------------------
    // FONCTIONS D'ÉCRITURE (Master Contract est le seul à appeler)
    // ----------------------------------------------------

    /**
     * @notice Enregistre un nouveau contrat de location.
     * @dev Seul le compte opérateur (owner) devrait appeler cette fonction.
     */
    function createNewLease(
        uint256 _dbContractId,
        uint256 _landlordId,
        uint256 _tenantId,
        uint256 _rentAmount,
        uint64 _endDate,
        string memory _status,
        string memory _depositStatus
    ) public {
        // Optionnel: Vérifier si l'appel vient bien de l'opérateur de l'API
        require(msg.sender == owner, "Seul le proprietaire du contrat peut creer"); 
        
        // Vérifie si l'ID n'est pas déjà utilisé
        require(contracts[_dbContractId].dbContractId == 0, "Contrat deja existant");

        contracts[_dbContractId] = RentalContract({
            dbContractId: _dbContractId,
            landlordId: _landlordId,
            tenantId: _tenantId,
            rentAmount: _rentAmount,
            endDate: _endDate,
            currentStatus: _status,
            depositStatus: _depositStatus
        });

        emit LeaseCreated(_dbContractId, msg.sender);
    }

    /**
     * @notice Met à jour la date de fin d'un bail existant.
     */
    function updateEndDate(uint256 _dbContractId, uint64 _newEndDate) public {
        require(msg.sender == owner, "Seul le proprietaire du contrat peut modifier");
        require(contracts[_dbContractId].dbContractId != 0, "Contrat introuvable");

        contracts[_dbContractId].endDate = _newEndDate;
        emit EndDateUpdated(_dbContractId, _newEndDate);
    }

    /**
     * @notice Met à jour le statut du bail (e.g., de 'pending' à 'active').
     */
    function updateStatus(uint256 _dbContractId, string memory _newStatus) public {
        require(msg.sender == owner, "Seul le proprietaire du contrat peut modifier");
        require(contracts[_dbContractId].dbContractId != 0, "Contrat introuvable");

        contracts[_dbContractId].currentStatus = _newStatus;
        emit StatusUpdated(_dbContractId, _newStatus);
    }

    // ----------------------------------------------------
    // FONCTIONS DE LECTURE (Optionnelles, utiles pour les tests)
    // ----------------------------------------------------

    function getContractStatus(uint256 _dbContractId) public view returns (string memory) {
        return contracts[_dbContractId].currentStatus;
    }
}