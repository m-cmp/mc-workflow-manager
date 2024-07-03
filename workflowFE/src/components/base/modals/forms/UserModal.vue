<template>
  <div class="modal fade" id="kt_modal_user" tabindex="-1" aria-hidden="true">
    <!--begin::Modal dialog-->
    <div class="modal-dialog modal-dialog-centered mw-650px">
      <!--begin::Modal content-->
      <div class="modal-content">
        <!--begin::Modal header-->
        <div class="modal-header" id="kt_modal_user_header">
          <!--begin::Modal title-->
          <h2 class="fw-bolder">Add a User</h2>
          <!--end::Modal title-->

          <!--begin::Close-->
          <div
            id="kt_modal_add_user_close"
            data-bs-dismiss="modal"
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
          id="kt_user_modal_form"
          :validation-schema="login"
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
                />
                <!--end::Input-->
                <div class="fv-plugins-message-container">
                  <div class="fv-help-block">
                    <ErrorMessage name="username" />
                  </div>
                </div>
              </div>
              <!--end::Input group-->
            </div>
          </div>
        </Form>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { ErrorMessage, Field, Form } from "vee-validate";
import * as Yup from "yup";

export default defineComponent({
  name: "user-modal",
  components: {
    Field,
    Form,
    ErrorMessage,
  },
  setup() {
    //Create form validation object
    const login = Yup.object().shape({
      //username: Yup.string().email().required().label("Email"),
      username: Yup.string().required().label("Name"),
    });

    return {
      login,
    };
  },
});
</script>
