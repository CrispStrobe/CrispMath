/// Matrix call names shared by evaluation and worksheet identifier classification.
/// Keep registration beside execution so supported calls never acquire false
/// unresolved-name badges or user definitions that shadow a matrix builtin.
const Set<String> kMatrixUnaryOperationNames = {
  'det', 'trace', 'inv', 'transpose', 'rref', 'eigenvalues', 'eigenvectors',
};
