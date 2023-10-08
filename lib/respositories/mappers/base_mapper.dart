abstract class BaseMapper<D, M> {
  M mapToModel(D data);
  D mapToData(M model);
}
