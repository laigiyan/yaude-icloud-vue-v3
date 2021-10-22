<template>
  <j-modal
    :title="title"
    :width="width"
    :visible="visible"
    switchFullscreen
    @ok="handleOk"
    :okButtonProps="{ class:{'jee-hidden': disableSubmit} }"
    @cancel="handleCancel"
    cancelText="關閉">
    <template slot="footer">
      <a-button @click="handleAgree" type="primary" v-show="showoption" :disabled=isExamine>同意</a-button>
      <a-button @click="handlerefuse" type="primary" v-show="showoption" :disabled=isExamine>拒絕</a-button>
      <a-button @click="handleOk" type="primary" v-show="!showoption">確定</a-button>
      <a-button @click="handleCancel">關閉</a-button>
    </template>
    <os-apply-floatip-form ref="realForm" @ok="submitCallback" :disabled="disableSubmit"></os-apply-floatip-form>
  </j-modal>
</template>

<script>

  import OsApplyFloatipForm from './OsApplyFloatipForm'
  export default {
    name: 'OsApplyFloatipModal',
    components: {
      OsApplyFloatipForm
    },
    data () {
      return {
        title:'',
        width:800,
        visible: false,
        disableSubmit: false,
        showoption: false,
        isExamine: false
      }
    },
    methods: {
      add () {
        this.visible=true
        this.$nextTick(()=>{
          this.$refs.realForm.add();
        })
      },
      edit (record) {
        this.visible=true
        if(record.status=="1" || record.status=="2"){
          this.isExamine=true;
        }
        this.showoption=record.showoption;
        this.$nextTick(()=>{
          this.$refs.realForm.edit(record);
        })
      },
      handleAgree(){
        this.visible=true
        this.$refs.realForm.agree();
        setTimeout(() => {
          this.$emit('agree');
        }, 500)
        this.close()
      },
      handlerefuse(){
        this.visible=true
        this.$refs.realForm.refuse();
        setTimeout(() => {
          this.$emit('refuse');
        }, 500)
        this.close()
      },
      close () {
        this.$emit('close');
        this.visible = false;
      },
      handleOk () {
        this.$refs.realForm.submitForm();
      },
      submitCallback(){
        this.$emit('ok');
        this.visible = false;
      },
      handleCancel () {
        this.close()
      }
    }
  }
</script>