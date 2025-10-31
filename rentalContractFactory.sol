// SPDX-License-Identifier: MIT
// Définit la licence du code (MIT est courante pour les projets open source).
pragma solidity ^0.8.20; // Spécifie la version du compilateur Solidity.

// ===================================================
// 🔹 1. CONTRAT PRINCIPAL ET STRUCTURES DE DONNÉES
// ===================================================

contract RentalContractFactory {
  // Structure (struct) pour représenter un Paiement.
  struct Payment {
    uint256 paymentId; // ID du paiement (souvent l'ID dans la base de données hors-chaîne).
    uint256 amount; // Montant du paiement.
    uint64 paymentDate; // Date et heure du paiement (timestamp Unix, 64 bits est suffisant).
    string paymentMethod; // Méthode de paiement (ex: "Virement", "Carte").
  }

  // Structure (struct) pour représenter un Contrat de Location (Bail).
  struct RentalContract {
    uint256 dbContractId; // ID du contrat dans la base de données hors-chaîne (clé unique).
    uint256 landlordId; // ID du propriétaire.
    uint256 tenantId; // ID du locataire.
    uint256 rentAmount; // Montant du loyer mensuel.
    string currency; // Devise utilisée (ex: "EUR", "USD").
    uint64 endDate; // Date de fin du contrat (timestamp).
    string currentStatus; // Statut actuel (ex: "Actif", "Résilié").
    uint256 depositMonths; // Nombre de mois de caution.
    uint256 depositAmount; // Montant total de la caution.
    string depositStatus; // Statut de la caution (ex: "Payée", "Bloquée").
    Payment[] payments; // Tableau pour stocker l'historique de tous les paiements.
  }

  // Mappage pour stocker tous les contrats. L'ID de la DB sert de clé unique pour retrouver le contrat.
  mapping(uint256 => RentalContract) public contracts;

  // Variables d'état permanentes (immutables), définies une seule fois à la création.
  address public immutable owner; // Adresse de déploiement (propriétaire du contrat).
  address public immutable operator; // Adresse autorisée à effectuer des transactions.

  // =============================
  // 🔹 2. ÉVÉNEMENTS (EVENTS)
  // =============================
  // Les événements sont stockés dans les logs de la transaction et sont plus faciles à lire hors-chaîne.
  event LeaseCreated(uint256 dbContractId, address indexed creator);
  event StatusUpdated(uint256 dbContractId, string newStatus);
  event EndDateUpdated(uint256 dbContractId, uint64 newEndDate);
  event PaymentMade(uint256 dbContractId, uint256 paymentId, uint256 amount);

  // =============================
  // 🔹 3. CONSTRUCTEUR ET MODIFIERS
  // =============================

  // Fonction appelée uniquement lors du déploiement du contrat.
  constructor() {
    owner = msg.sender; // Définit le déployeur comme propriétaire.
    operator = msg.sender; // Définit le déployeur comme opérateur par défaut.
  }

  // Modificateur pour restreindre l'accès aux fonctions.
  modifier onlyAuthorized() {
    // Exige que l'appelant (msg.sender) soit l'owner OU l'operator.
    require(
      msg.sender == owner || msg.sender == operator,
      "Unauthorized caller"
    );
    _; // Exécute le reste de la fonction.
  }

  // =============================
  // 🔹 4. FONCTIONS DE GESTION
  // =============================

  // Fonction pour créer un nouveau contrat de location (bail) sur la chaîne.
  function createNewLease(
    uint256 _dbContractId,
    uint256 _landlordId,
    uint256 _tenantId,
    uint64 _endDate,
    uint256 _rentAmount,
    string memory _currency,
    string memory _status,
    uint256 _depositMonths,
    uint256 _depositAmount,
    string memory _depositStatus
  ) public onlyAuthorized { // Seul l'opérateur ou le propriétaire peut appeler cette fonction.
    // Vérifie qu'aucun contrat avec cet ID n'existe déjà.
    require(contracts[_dbContractId].dbContractId == 0, "Lease already exists");

    // Crée une référence de stockage pour le nouveau contrat dans le mapping.
    RentalContract storage newContract = contracts[_dbContractId];

    // Initialise les champs du nouveau contrat.
    newContract.dbContractId = _dbContractId;
    newContract.landlordId = _landlordId;
    newContract.tenantId = _tenantId;
    newContract.endDate = _endDate;
    newContract.rentAmount = _rentAmount;
    newContract.currency = _currency;
    newContract.currentStatus = _status;
    newContract.depositMonths = _depositMonths;
    newContract.depositAmount = _depositAmount;
    newContract.depositStatus = _depositStatus;

    // Émet un événement pour signaler la création.
    emit LeaseCreated(_dbContractId, msg.sender);
  }

  // Fonction pour enregistrer un paiement.
  function makePayment(
    uint256 _dbContractId,
    uint256 _paymentId,
    uint256 _amount,
    string memory _paymentMethod
  ) public onlyAuthorized {
    // Vérifie que le contrat existe.
    require(contracts[_dbContractId].dbContractId != 0, "Lease not found");

    // Ajoute un nouveau paiement au tableau des paiements du contrat.
    contracts[_dbContractId].payments.push(
      Payment({
        paymentId: _paymentId,
        amount: _amount,
        paymentDate: uint64(block.timestamp), // Utilise le timestamp actuel de la blockchain.
        paymentMethod: _paymentMethod
      })
    );

    // Émet un événement pour signaler le paiement.
    emit PaymentMade(_dbContractId, _paymentId, _amount);
  }

  // Fonction pour modifier la date de fin du contrat (ex: renouvellement).
  function updateEndDate(uint256 _dbContractId, uint64 _newEndDate) public onlyAuthorized {
    require(contracts[_dbContractId].dbContractId != 0, "Lease not found");

    contracts[_dbContractId].endDate = _newEndDate;
    emit EndDateUpdated(_dbContractId, _newEndDate);
  }

  // Fonction pour modifier le statut du contrat (ex: de "Actif" à "Résilié").
  function updateStatus(uint256 _dbContractId, string memory _newStatus) public onlyAuthorized {
    require(contracts[_dbContractId].dbContractId != 0, "Lease not found");

    contracts[_dbContractId].currentStatus = _newStatus;
    emit StatusUpdated(_dbContractId, _newStatus);
  }
}
