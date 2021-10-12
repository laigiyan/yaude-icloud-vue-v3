<template>
  <j-modal
    :title="title"
    :width="width"
    :visible="visible"
    switchFullscreen
    @ok="handleOk"
    :okButtonProps="{ class:{'jee-hidden': disableSubmit} }"
    @cancel="handleCancel"
    cancelText="关闭">
    <os-apply-form ref="realForm" @ok="submitCallback" :disabled="disableSubmit"></os-apply-form>
    <div v-show="showoption">
      <a-button @click="handleAgree(record)" type="primary"  >同意</a-button>
      <a-button @click="handlerefuse" type="primary" >拒绝</a-button>
    </div>
  </j-modal>
</template>

<script>

  import OsApplyForm from './OsApplyForm'
  export default {
    name: 'OsApplyModal',
    components: {
      OsApplyForm
    },
    data () {
      return {
        title:'',
        width:800,
        visible: false,
        disableSubmit: false,
        showoption: false
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
        this.showoption=record.showoption;
        debugger
        this.$nextTick(()=>{
          this.$refs.realForm.edit(record);
        })
      },
      handleAgree(){
        this.visible=true
        this.$nextTick(()=>{
          this.$refs.realForm.agree();
        })
        this.close()
      },
      handlerefuse(){
        this.visible=true
        this.$nextTick(()=>{
          this.$refs.realForm.refuse();
        })
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