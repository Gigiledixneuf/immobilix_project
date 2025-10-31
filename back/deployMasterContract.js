// Script Node.js pour le déploiement initial du Smart Contract ImmobilX sur Hedera Testnet.
//
// USAGE:
// 1️⃣ Place le fichier compilé (.bin) à la racine du projet
// 2️⃣ Configure ton fichier .env avec HEDERA_ACCOUNT_ID et HEDERA_PRIVATE_KEY
// 3️⃣ Lance : node scripts/deployMasterContract.js
//
// Le script affichera le MASTER_CONTRACT_ID à copier dans le fichier .env.

// Importe les variables d'environnement (dotenv/config)
import 'dotenv/config'
import {
  // Classes et fonctions essentielles du SDK Hedera
  Client,
  FileCreateTransaction,
  FileAppendTransaction, // Importé pour l'ajout de morceaux de bytecode
  ContractCreateTransaction,
  PrivateKey,
  Hbar, // Unité de compte Hedera
  AccountId,
  AccountBalanceQuery, // Pour vérifier le solde
} from '@hashgraph/sdk';
import fs from 'fs'; // Module pour interagir avec le système de fichiers

// ===================================================
// 🔹 1. CONFIGURATION INITIALE
// ===================================================

// ✅ Chemin vers ton bytecode compilé du smart contract
const BYTECODE_PATH = "./rentalContractFactory_sol_RentalContractFactory.bin";

// Taille maximale recommandée d'un chunk pour FileAppendTransaction (4096 octets)
// Diminution à 2048 octets pour une meilleure résilience sur Testnet congestionné.
const MAX_CHUNK_SIZE = 2048;

// Fonction utilitaire pour attendre un certain nombre de millisecondes
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Découpe un buffer de bytecode en morceaux de taille maximale.
 * @param {Buffer} bytecode Le contenu du fichier.
 * @returns {Buffer[]} Un tableau de buffers (chunks).
 */
function chunkBytecode(bytecode) {
  const chunks = [];
  // Boucle pour découper le buffer en morceaux (chunks)
  for (let i = 0; i < bytecode.length; i += MAX_CHUNK_SIZE) {
    chunks.push(bytecode.slice(i, i + MAX_CHUNK_SIZE));
  }
  return chunks;
}


// ===================================================
// 🔹 2. LOGIQUE DE DÉPLOIEMENT
// ===================================================

async function deployMasterContract() {
  try {
    // --- Vérification des variables d'environnement ---
    if (!process.env.HEDERA_ACCOUNT_ID || !process.env.HEDERA_PRIVATE_KEY) {
      throw new Error("Veuillez configurer HEDERA_ACCOUNT_ID et HEDERA_PRIVATE_KEY dans le fichier .env.");
    }

    if (!fs.existsSync(BYTECODE_PATH)) {
      throw new Error(`Fichier bytecode non trouvé : ${BYTECODE_PATH}`);
    }

    // --- Initialisation du compte opérateur ---
    const operatorId = process.env.HEDERA_ACCOUNT_ID;
    let cleanedKey = process.env.HEDERA_PRIVATE_KEY.replace(/\s/g, '').trim();
    if (cleanedKey.startsWith('0x')) {
      cleanedKey = cleanedKey.substring(2);
    }

    // 🚨 Le SDK vous a demandé d'utiliser fromStringECDSA() ou fromStringED25519().
    // On utilise la clé privée de l'opérateur pour signer les transactions.
    const operatorKey = PrivateKey.fromStringECDSA(cleanedKey);


    // 🚀 MISE À JOUR DU CLIENT POUR LA COMPATIBILITÉ ET LA RÉSILIENCE
    // 1. Initialisation de base du client pour le réseau de test (Testnet)
    const client = Client.forTestnet()
      .setOperator(operatorId, operatorKey);

    // 2. Application des configurations avancées
    // 🚨 Augmente le timeout de transaction (30s) pour les gros déploiments (Résilience gRPC)
    client.setRequestTimeout(30 * 1000);


    console.log(`-> Vérification du solde de l'opérateur ${operatorId}...`);

    // --- Vérification du solde du compte ---
    const accountId = AccountId.fromString(operatorId);
    const balanceQuery = new AccountBalanceQuery().setAccountId(accountId);

    try {
      const accountBalance = await balanceQuery.execute(client);
      const balanceInHbar = parseFloat(accountBalance.hbars.toString());

      console.log(`✅ Solde vérifié : ${balanceInHbar.toLocaleString()} Hbar.`);
      if (balanceInHbar < 1) {
        console.warn("⚠️ Solde bas : moins de 1 Hbar. Le déploiement pourrait échouer.");
      }
    } catch (balanceError) {
      console.error("\n❌ ERREUR LORS DE LA VÉRIFICATION DU SOLDE :");
      throw new Error(`Échec de la vérification du solde pour le compte ${operatorId}.`);
    }

    // --- Lecture et Découpage du bytecode ---
    const bytecode = fs.readFileSync(BYTECODE_PATH);
    const chunks = chunkBytecode(bytecode);
    console.log("-> Bytecode chargé. Taille :", bytecode.length, "octets.");
    console.log(`-> Découpé en ${chunks.length} morceaux (max ${MAX_CHUNK_SIZE} octets par morceau).`);


    // =======================================================================
    // 🚀 MÉTHODE ROBUSTE EN 3 ÉTAPES : Création + Ajout + Création Contrat
    // =======================================================================

    // --- ÉTAPE 1 : Créer le fichier sur Hedera avec le premier morceau ---
    console.log("-> 1/3 : Création du fichier avec le premier morceau...");

    let fileId = null;
    const maxAttempts = 3; // Nombre maximal de tentatives en cas d'erreur réseau

    try {
      // Créer le fichier avec le premier morceau (chunks[0])
      let fileCreateTx = new FileCreateTransaction()
        .setContents(chunks[0])
        .setKeys([operatorKey.publicKey]) // Définit l'Admin Key du fichier
        .setMaxTransactionFee(new Hbar(5)); // Définit le coût max (fee) de la transaction

      // 💡 AJOUT CRUCIAL : Forcer la signature de l'opérateur
      const signedFileCreateTx = await fileCreateTx.freezeWith(client).sign(operatorKey);

      const fileSubmit = await signedFileCreateTx.execute(client);
      const fileReceipt = await fileSubmit.getReceipt(client); // Attend la confirmation

      if (fileReceipt.status.toString() !== 'SUCCESS') {
        throw new Error(`Statut de la création de fichier non réussi: ${fileReceipt.status.toString()}`);
      }

      fileId = fileReceipt.fileId;
      console.log(`✅ Fichier créé. File ID: ${fileId.toString()}`);

    } catch (e) {
      // Gestion des erreurs de création de fichier, incluant les problèmes de signature
      const errorStr = e.message || e.toString();
      if (errorStr.includes('INVALID_SIGNATURE')) {
        console.error("💡 Conseil : Vérifiez que HEDERA_PRIVATE_KEY est correcte pour HEDERA_ACCOUNT_ID.");
      }
      throw new Error(`Échec de la création du fichier (premier morceau).`);
    }


    // --- ÉTAPE 2 : Ajouter les morceaux restants (Append) ---
    if (chunks.length > 1) {
      console.log("-> 2/3 : Ajout des morceaux restants...");

      for (let i = 1; i < chunks.length; i++) {
        let attempt = 0;
        let success = false;

        do {
          attempt++;
          console.log(`   Ajout du morceau ${i + 1}/${chunks.length}. Tentative ${attempt}/${maxAttempts}...`);

          try {
            let fileAppendTx = new FileAppendTransaction()
              .setFileId(fileId) // Cible le fichier créé à l'étape 1
              .setContents(chunks[i]) // Contenu du morceau actuel
              .setMaxTransactionFee(new Hbar(5));

            // NOTE: FileAppendTransaction doit être signée par l'AdminKey (ici l'opérateur)
            const signedFileAppendTx = await fileAppendTx.freezeWith(client).sign(operatorKey);


            const appendSubmit = await signedFileAppendTx.execute(client);
            const appendReceipt = await appendSubmit.getReceipt(client); // Attend la confirmation

            if (appendReceipt.status.toString() === 'SUCCESS') {
              console.log(`   ✅ Morceau ${i + 1} ajouté avec succès (Tentative ${attempt}).`);
              success = true;
              await sleep(2000); // Pause pour éviter la congestion
            } else {
              throw new Error(`Statut de l'ajout non réussi: ${appendReceipt.status.toString()}`);
            }

          } catch (e) {
            const errorStr = e.message || e.toString();

            // Logique de réessai en cas d'erreur réseau temporaire (UNKNOWN, BUSY, etc.)
            if (attempt < maxAttempts && (errorStr.includes('UNKNOWN') || errorStr.includes('NODE_TRANSACTION_PRECHECK_FAILED') || errorStr.includes('BUSY'))) {
              console.warn(`   ❌ Échec de l'ajout (Erreur réseau/nœud). Attente avant de réessayer...`);
              await sleep(5000);
            } else {
              // Échec définitif
              console.error(`\n❌ ERREUR LORS DE L'AJOUT DU MORCEAU ${i + 1} : ${errorStr}`);
              throw new Error(`Échec définitif de l'ajout du morceau ${i + 1} après ${maxAttempts} tentatives.`);
            }
          }
        } while (!success && attempt < maxAttempts);

        if (!success) {
          throw new Error(`Échec critique de l'ajout du morceau ${i + 1}. Arrêt du déploiement.`);
        }
      }
      console.log("✅ Tous les morceaux ont été ajoutés.");
    }


    // --- ÉTAPE 3 : Créer l'instance du Smart Contract ---
    console.log("-> 3/3 : Création de l'instance du Master Contract à partir du File ID...");

    let contractCreateTx = new ContractCreateTransaction()
      // 🚀 CORRECTION : Augmentation du gaz à 2.5 millions pour résoudre INSUFFICIENT_GAS
      .setGas(2500000)
      .setBytecodeFileId(fileId) // Utilise le File ID de l'étape 1 (contenant tout le bytecode)
      .setAdminKey(operatorKey.publicKey); // Définit l'Admin Key du contrat

    const contractSubmit = await contractCreateTx.execute(client);
    const contractReceipt = await contractSubmit.getReceipt(client); // Attend la confirmation

    if (contractReceipt.status.toString() !== 'SUCCESS') {
      throw new Error(`Échec de la création du contrat: ${contractReceipt.status.toString()}`);
    }

    const masterContractId = contractReceipt.contractId.toString();

    console.log("\n=============================================");
    console.log("🎉 DÉPLOIEMENT MASTER CONTRACT RÉUSSI ! 🎉");
    console.log("MASTER CONTRACT ID (À COPIER dans .env):");
    console.log(`HEDERA_MASTER_CONTRACT_ID="${masterContractId}"`);
    console.log("=============================================");

    return masterContractId;

  } catch (error) {
    console.error("\n❌ ERREUR LORS DU DÉPLOIEMENT HEDERA :");
    console.error("🔍 Erreur détaillée :", error.message || error);
    process.exit(1); // Quitte le processus avec un code d'erreur
  }
}

deployMasterContract();
