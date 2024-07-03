import router from "./router";

router.beforeEach(async (to, from, next) => {
  console.log('## to ### : ', to)
  console.log('## from ### : ', from)

  next();
});