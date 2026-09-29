abstract class BaseRepository<T, ID> {
  Future<List<T>> getAll();
  Future<T?> getById(ID id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<void> delete(ID id);
}
