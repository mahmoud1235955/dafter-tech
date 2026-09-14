import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/add_customer_usecase.dart';
import '../../domain/usecases/delete_customer_usecase.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/search_customers_usecase.dart';
import '../../domain/usecases/sync_customers_usecase.dart';
import '../../domain/usecases/update_customer_usecase.dart';
import 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final GetCustomersUseCase getCustomersUseCase;
  final AddCustomerUseCase addCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;
  final SearchCustomersUseCase searchCustomersUseCase;
  final SyncCustomersUseCase syncCustomersUseCase;

  List<CustomerEntity> _allCustomers = [];

  CustomerCubit({
    required this.getCustomersUseCase,
    required this.addCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
    required this.searchCustomersUseCase,
    required this.syncCustomersUseCase,
  }) : super(CustomerInitial());

  Future<void> loadCustomers() async {
    emit(CustomerLoading());
    final result = await getCustomersUseCase(NoParams());

    result.fold((failure) => emit(CustomerError(failure.message)), (customers) {
      _allCustomers = customers;
      emit(
        CustomerLoaded(
          customers: _allCustomers,
          filteredCustomers: _allCustomers,
        ),
      );
    });
  }

  Future<void> createCustomer(CustomerEntity customer) async {
    emit(CustomerLoading());
    final result = await addCustomerUseCase(customer);

    result.fold((failure) => emit(CustomerError(failure.message)), (_) async {
      emit(const CustomerActionSuccess('تمت إضافة العميل بنجاح'));
      await loadCustomers();
    });
  }

  Future<void> editCustomer(CustomerEntity customer) async {
    emit(CustomerLoading());
    final result = await updateCustomerUseCase(customer);

    result.fold((failure) => emit(CustomerError(failure.message)), (_) async {
      emit(const CustomerActionSuccess('تم تعديل بيانات العميل بنجاح'));
      await loadCustomers();
    });
  }

  Future<void> removeCustomer(String customerId) async {
    emit(CustomerLoading());
    final result = await deleteCustomerUseCase(customerId);

    result.fold((failure) => emit(CustomerError(failure.message)), (_) async {
      emit(const CustomerActionSuccess('تم حذف العميل بنجاح'));
      await loadCustomers();
    });
  }

  void searchCustomer(String query) {
    if (state is CustomerLoaded) {
      if (query.trim().isEmpty) {
        emit(
          CustomerLoaded(
            customers: _allCustomers,
            filteredCustomers: _allCustomers,
          ),
        );
      } else {
        final filtered = _allCustomers
            .where(
              (c) =>
                  c.name.toLowerCase().contains(query.toLowerCase()) ||
                  c.phone.contains(query),
            )
            .toList();

        emit(
          CustomerLoaded(customers: _allCustomers, filteredCustomers: filtered),
        );
      }
    }
  }

  Future<void> syncData() async {
    final result = await syncCustomersUseCase(NoParams());
    result.fold((failure) => null, (_) => loadCustomers());
  }
}
