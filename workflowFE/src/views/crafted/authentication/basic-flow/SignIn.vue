<!-- ################################################################################################################### -->

<template>
  <!--begin::Wrapper-->
  <div class="w-lg-500px bg-white rounded shadow-sm p-10 p-lg-15 mx-auto">
    <!--begin::Form-->
    <Form
      class="form w-100"
      id="kt_login_signin_form"
      @submit="onSubmitLogin"
      :validation-schema="login"
    >
      <!--begin::Heading-->
      <div class="text-center mb-10">
        <!--begin::Title-->
        <h1 class="text-dark mb-3">Sign in to M-CMP</h1>
        <!--end::Title-->
      </div>
      <!--end::Heading-->

      <div class="mb-10 bg-light-info p-8 rounded">
        <div class="text-info">
          임시 계정: <strong>m-cmp</strong> &emsp; 암호:
          <strong>!Q.....</strong>
        </div>
      </div>

      <!--begin::Input group-->
      <div class="fv-row mb-10">
        <!--begin::Label-->
        <label class="form-label fs-6 fw-bolder text-dark">{{ $t("auth_id") }}</label>
        <!--end::Label-->

        <!--begin::Input-->
        <Field
          class="form-control form-control-lg form-control-solid"
          type="text"
          name="userId"
          autocomplete="off"
        />
        <!--end::Input-->
        <div class="fv-plugins-message-container">
          <div class="fv-help-block">
            <ErrorMessage name="userId" />
          </div>
        </div>
      </div>
      <!--end::Input group-->

      <!--begin::Input group-->
      <div class="fv-row mb-10">
        <!--begin::Wrapper-->
        <div class="d-flex flex-stack mb-2">
          <!--begin::Label-->
          <label class="form-label fw-bolder text-dark fs-6 mb-0">
            {{ $t("auth_password") }}</label
          >
          <!--end::Label-->
        </div>
        <!--end::Wrapper-->

        <!--begin::Input-->
        <Field
          class="form-control form-control-lg form-control-solid"
          type="password"
          name="password"
          autocomplete="off"
        />
        <!--end::Input-->
        <div class="fv-plugins-message-container">
          <div class="fv-help-block">
            <ErrorMessage name="password" />
          </div>
        </div>
      </div>
      <!--end::Input group-->

      <!--begin::Actions-->
      <div class="text-center">
        <!--begin::Submit button-->
        <button
          type="submit"
          ref="submitButton"
          id="kt_sign_in_submit"
          class="btn btn-lg btn-primary w-100 mb-5"
        >
          <span class="indicator-label"> Login </span>

          <span class="indicator-progress">
            Please wait...
            <span
              class="spinner-border spinner-border-sm align-middle ms-2"
            ></span>
          </span>
        </button>
        <!--end::Submit button-->
      </div>
      <!--end::Actions-->
    </Form>
    <!--end::Form-->
  </div>
  <!--end::Wrapper-->
</template>

<!-- ################################################################################################################### -->

<script lang="ts">
import Vue, { defineComponent, ref } from "vue";
import { ErrorMessage, Field, Form } from "vee-validate";
import { Actions } from "@/store/enums/StoreEnums";
import { useStore } from "vuex";
import { useRouter } from "vue-router";
import Swal from "sweetalert2/dist/sweetalert2.min.js";
import * as Yup from "yup";
import { useI18n } from "vue-i18n";

export default defineComponent({
  name: "SignIn",
  components: {
    Field,
    Form,
    ErrorMessage,
  },
  setup() {
    const store = useStore();
    const router = useRouter();
    const { t } = useI18n();

    const submitButton = ref<HTMLButtonElement | null>(null);

    //Create form validation object
    const login = Yup.object().shape({
      userId: Yup.string().trim().required().min(2).label("Id"),
      password: Yup.string().min(4).required().label("Password"),
    });

    //Form submit function
    const onSubmitLogin = (values) => {
      // Clear existing errors
      store.dispatch(Actions.LOGOUT);

      if (submitButton.value) {
        // eslint-disable-next-line
                submitButton.value!.disabled = true;
        // Activate indicator
        submitButton.value.setAttribute("data-kt-indicator", "on");
      }

      values.password = btoa(values.password);
      /* 로그인 실행 */
      store
        .dispatch(Actions.LOGIN, values)
        .then(() => {
          console.log("signIn_success: " + t("signIn_success"));
          Swal.fire({
            text: t("signIn_success"),
            icon: "success",
            buttonsStyling: false,
            confirmButtonText: t("ok"),
            customClass: {
              confirmButton: "btn fw-bold btn-light-primary",
            },
          }).then(function () {
            // Go to page after successfully login
            router.push({ name: "dashboard" });
          });
        })
        .catch(() => {
          console.log("signIn_fail: ");

          const [error] = Object.keys(store.getters.getErrors);
          console.dir(store.getters.getErrors[error]);

          Swal.fire({
            text: store.getters.getErrors[error],
            icon: "error",
            buttonsStyling: false,
            confirmButtonText: t("ok"),
            customClass: {
              confirmButton: "btn fw-bold btn-light-danger",
            },
          });
        });

      submitButton.value?.removeAttribute("data-kt-indicator");
      submitButton.value!.disabled = false;
    };

    return {
      onSubmitLogin,
      login,
      submitButton,
    };
  },
});
</script>
