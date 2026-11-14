enum DevUserRole { custodian, supervisor }

final class DevAuth {
  DevAuth._();

  static const String password = '123456';
  static const String custodianEmail = 'custodian@gmail.com';
  static const String supervisorEmail = 'supervisor@gmail.com';

  static DevUserRole? roleForCredentials({
    required String email,
    required String password,
  }) {
    if (password != DevAuth.password) return null;

    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail == custodianEmail) return DevUserRole.custodian;
    if (normalizedEmail == supervisorEmail) return DevUserRole.supervisor;

    return null;
  }

  static String emailForRole(DevUserRole role) {
    return switch (role) {
      DevUserRole.custodian => custodianEmail,
      DevUserRole.supervisor => supervisorEmail,
    };
  }

  static String storageValueForRole(DevUserRole role) {
    return switch (role) {
      DevUserRole.custodian => 'custodian',
      DevUserRole.supervisor => 'supervisor',
    };
  }
}
