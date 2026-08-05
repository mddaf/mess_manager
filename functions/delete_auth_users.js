const admin = require('firebase-admin');

// Initialize with default credentials or project ID
admin.initializeApp({
  projectId: 'meal-manager-844f5'
});

async function clearAuthUsers(nextPageToken) {
  try {
    const listUsersResult = await admin.auth().listUsers(1000, nextPageToken);
    const uids = listUsersResult.users.map(user => user.uid);
    
    if (uids.length > 0) {
      const deleteResult = await admin.auth().deleteUsers(uids);
      console.log(`Successfully deleted ${deleteResult.successCount} users from Firebase Auth.`);
      if (deleteResult.failureCount > 0) {
        console.log(`Failed to delete ${deleteResult.failureCount} users.`);
      }
    } else {
      console.log('No users found in Firebase Authentication.');
    }

    if (listUsersResult.pageToken) {
      await clearAuthUsers(listUsersResult.pageToken);
    }
  } catch (error) {
    console.error('Error deleting users:', error);
  }
}

clearAuthUsers();
