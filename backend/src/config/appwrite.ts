// backend/src/config/appwrite.ts
// Purpose: Appwrite SDK client configuration

import { Client, Account, Databases } from "appwrite";

const client = new Client()
    .setEndpoint("https://fra.cloud.appwrite.io/v1")
    .setProject("698a195a0001c5847a94");

const account = new Account(client);
const databases = new Databases(client);

export { client, account, databases };
