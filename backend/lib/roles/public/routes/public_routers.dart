import 'package:shelf_router/shelf_router.dart';
import "../controllers/public_controller.dart";
import 'package:backend/roles/public/controllers/public_recommend_controller.dart';

Router publicRoutes() {
  final router = Router();

  final public = PublicController();
  final recom =  PublicRecommendController(); 

  // ===== PUBLIC =====
  router.get('/category/<categoryId>', public.getCategoryById);
  router.get('/categories', public.getAllCategories);
  router.get('/reviews/<foodId>', public.getReviewsFood);
  router.get('/userInfo/<userId>', public.getInfoUser);
  router.get('/reviews/count/<foodId>', public.countReviewsByFoodId);
  router.get('/paymentMethod/<methodPayment>', public.getPaymentMethodId);
  router.get('/recommendations/<foodId>', recom.getRecommendations);
  router.get('/foods/search',  public.searchFoods);

  return router;
}
