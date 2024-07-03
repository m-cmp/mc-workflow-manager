<template>
  <Modal ref="baseModal">
    <!--begin::Modal header-->
    <div class="modal-header" id="kt_modal_user_header">
      <!--begin::Modal title-->
      <h2 class="fw-bolder">{{ modalTitle }} a User</h2>
      <!--end::Modal title-->

      <!--begin::Close-->
      <div
        @click="onCancel"
        class="btn btn-icon btn-sm btn-active-icon-primary"
      >
        <span class="svg-icon svg-icon-1">
          <inline-svg src="media/icons/duotune/arrows/arr061.svg" />
        </span>
      </div>
      <!--end::Close-->
    </div>
    <!--end::Modal header-->

    <Form
      class="form w-100"
      @submit="onSubmitLogin"
      :validation-schema="formValidation"
    >
      <!--begin::Modal body-->
      <div class="modal-body py-10 px-lg-17">
        <!--begin::Scroll-->
        <div
          class="scroll-y me-n7 pe-7"
          id="kt_modal_user_scroll"
          data-kt-scroll="true"
          data-kt-scroll-activate="{default: false, lg: true}"
          data-kt-scroll-max-height="auto"
          data-kt-scroll-dependencies="#kt_modal_user_header"
          data-kt-scroll-wrappers="#kt_modal_user_scroll"
          data-kt-scroll-offset="300px"
        >
          <!--begin::Input group-->
          <div class="fv-row mb-7">
            <!--begin::Label-->
            <label class="required fs-6 fw-bold mb-2">Name</label>
            <!--end::Label-->

            <!--begin::Input-->
            <Field
              class="form-control form-control-lg form-control-solid"
              type="text"
              name="username"
              autocomplete="off"
              :value="modalParam.username"
            />
            <!--end::Input-->
            <div class="fv-plugins-message-container">
              <div class="fv-help-block">
                <ErrorMessage name="username" />
              </div>
            </div>
          </div>
          <!--end::Input group-->

          <!--begin::Input group-->
          <div class="fv-row mb-7">
            <!--begin::Label-->
            <label class="required fs-6 fw-bold mb-2">Email</label>
            <!--end::Label-->

            <!--begin::Input-->
            <Field
              class="form-control form-control-lg form-control-solid"
              type="text"
              name="email"
              autocomplete="off"
              :value="modalParam.email"
            />
            <!--end::Input-->
            <div class="fv-plugins-message-container">
              <div class="fv-help-block">
                <ErrorMessage name="email" />
              </div>
            </div>
          </div>
          <!--end::Input group-->

          <!--begin::Input group-->
          <div class="fv-row mb-7">
            <!--begin::Label-->
            <label class="fs-6 fw-bold mb-2">Address</label>
            <!--end::Label-->

            <!--begin::Input-->
            <Field
              class="form-control form-control-lg form-control-solid"
              type="text"
              name="address"
              autocomplete="off"
              :value="modalParam.address.city"
            />
            <!--end::Input-->
            <div class="fv-plugins-message-container">
              <div class="fv-help-block">
                <ErrorMessage name="address" />
              </div>
            </div>
          </div>
          <!--end::Input group-->

          <!--begin::Input group-->
          <div class="fv-row mb-7">
            <!--begin::Label-->
            <label class="fs-6 fw-bold mb-2">Company</label>
            <!--end::Label-->

            <!--begin::Input-->
            <Field
              class="form-control form-control-lg form-control-solid"
              type="text"
              name="company"
              autocomplete="off"
              :value="modalParam.company.name"
            />
            <!--end::Input-->
            <div class="fv-plugins-message-container">
              <div class="fv-help-block">
                <ErrorMessage name="company" />
              </div>
            </div>
          </div>
          <!--end::Input group-->
        </div>
      </div>
      <!--end::Modal body-->

      <!--begin::Modal footer-->
      <div class="modal-footer flex-center">
        <!--begin::Button-->
        <button type="reset" class="btn btn-light me-3" @click="onCancel">
          Close
        </button>
        <!--end::Button-->

        <!--begin::Button-->
        <button class="btn btn-lg btn-primary" type="submit" ref="submitButton">
          <span class="indicator-label"> Submit </span>

          <span class="indicator-progress">
            Please wait...
            <span
              class="spinner-border spinner-border-sm align-middle ms-2"
            ></span>
          </span>
        </button>
        <!--end::Button-->
      </div>
    </Form>
  </Modal>
</template>

<script lang="ts">
import Modal from "@/components/base/user/Modal.vue";
import { ErrorMessage, Field, Form } from "vee-validate";
import * as Yup from "yup";
import { ref } from "vue";

export default {
  name: "ConfirmationModal",
  components: {
    Modal,
    Field,
    Form,
    ErrorMessage,
  },
  // 렌더링할 객체를 가져옵니다.
  props: ["modalParam", "modalTitle"],
  setup() {
    // 자식 컴포넌트를 핸들링하기 위한 ref
    const baseModal = ref();
    // Promise 객체를 핸들링하기 위한 ref
    const resolvePromise = ref();

    const show = () => {
      // baseModal을 직접 컨트롤합니다.
      baseModal.value.open();

      // Promise 객체를 사용하여, 현재 모달에서 확인 / 취소의
      // 응답이 돌아가기 전까지 작업을 기다리게 할 수 있습니다.
      return new Promise((resolve) => {
        // resolve 함수를 담아 외부에서 사용합니다.
        resolvePromise.value = resolve;
      });
    };

    const onCancel = () => {
      baseModal.value.close();
      resolvePromise.value(null);
    };

    //Create form validation object
    const formValidation = Yup.object().shape({
      //username: Yup.string().email().required().label("Email"),
      username: Yup.string().required().label("Name"),
      email: Yup.string().email().required().label("Email"),
    });

    const submitButton = ref<HTMLButtonElement | null>(null);

    //Form submit function
    const onSubmitLogin = (values) => {
      // console.log(values);

      if (submitButton.value) {
        // eslint-disable-next-line
        submitButton.value!.disabled = true;
        // Activate indicator
        submitButton.value.setAttribute("data-kt-indicator", "on");
      }

      // Dummy delay
      setTimeout(() => {
        // Send login request

        //Deactivate indicator
        submitButton.value?.removeAttribute("data-kt-indicator");
        // eslint-disable-next-line
        submitButton.value!.disabled = false;

        baseModal.value.close();
        resolvePromise.value(values);
      }, 2000);
    };

    return {
      baseModal,
      show,
      onCancel,
      formValidation,
      onSubmitLogin,
      submitButton,
    };
  },
};
</script>
